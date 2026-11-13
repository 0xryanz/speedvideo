package store

import (
	"context"
	"errors"
	"fmt"
	"regexp"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
	"gorm.io/gorm"

	"github.com/pagefau1t/speedvideo/collector/internal/adapter"
	"github.com/pagefau1t/speedvideo/collector/internal/model"
)

// Outcome reports what an upsert did.
type Outcome int

const (
	// OutcomeUnchanged means the content hash matched and nothing was written.
	OutcomeUnchanged Outcome = iota
	// OutcomeCreated means a new title row was inserted.
	OutcomeCreated
	// OutcomeUpdated means metadata or episodes changed.
	OutcomeUpdated
)

// UpsertTitle writes a provider title into the catalogue transactionally and
// records its content hash for change detection.
//
// The title id is stable across re-collection, so watchlists, progress and
// download records survive a refresh.
func (s *Store) UpsertTitle(
	ctx context.Context,
	src *model.Source,
	item *adapter.Title,
	hash string,
) (string, Outcome, error) {
	var (
		titleID string
		outcome = OutcomeUnchanged
	)
	key := workKeyOf(item)

	err := s.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		var existing model.Item
		itemErr := tx.Where("source_id = ? AND remote_id = ?", src.ID, item.RemoteID).
			First(&existing).Error
		if itemErr != nil && !errors.Is(itemErr, gorm.ErrRecordNotFound) {
			return fmt.Errorf("load collect item: %w", itemErr)
		}

		var title model.Title
		titleErr := tx.Where("source_id = ? AND remote_id = ?", src.ID, item.RemoteID).
			First(&title).Error

		switch {
		case errors.Is(titleErr, gorm.ErrRecordNotFound):
			title = model.Title{
				ID:             uuid.NewString(),
				Slug:           slugFor(src.Slug, item.RemoteID),
				Name:           item.Name,
				OriginalName:   item.OriginalName,
				Kind:           item.Kind,
				Synopsis:       item.Synopsis,
				ReleaseYear:    item.Year,
				MaturityRating: "18+",
				PosterPath:     item.PosterURL,
				BackdropPath:   item.PosterURL,
				VideoURL:       item.VideoURL,
				SourceID:       &src.ID,
				RemoteID:       item.RemoteID,
				WorkKey:        key,
				Canonical:      true,
				Popularity:     50,
				MatchPercent:   90,
			}
			if err := tx.Create(&title).Error; err != nil {
				return fmt.Errorf("create title: %w", err)
			}
			outcome = OutcomeCreated
		case titleErr != nil:
			return fmt.Errorf("load title: %w", titleErr)
		default:
			if itemErr == nil && existing.ContentHash == hash && existing.RemovedAt == nil &&
				title.RemovedAt == nil && title.WorkKey == key {
				titleID = title.ID
				return touchItem(tx, src.ID, item.RemoteID, title.ID, hash)
			}
			outcome = OutcomeUpdated
			if err := tx.Model(&title).Updates(map[string]any{
				"name":          item.Name,
				"original_name": item.OriginalName,
				"kind":          item.Kind,
				"synopsis":      item.Synopsis,
				"release_year":  item.Year,
				"poster_path":   item.PosterURL,
				"backdrop_path": item.PosterURL,
				"video_url":     item.VideoURL,
				"work_key":      key,
				"removed_at":    nil,
				"updated_at":    time.Now().UTC(),
			}).Error; err != nil {
				return fmt.Errorf("update title: %w", err)
			}
			if err := replaceSeasons(tx, title.ID, item); err != nil {
				return err
			}
			if err := replaceGenres(tx, &title, item.Genres); err != nil {
				return err
			}
			titleID = title.ID
			if err := touchItem(tx, src.ID, item.RemoteID, title.ID, hash); err != nil {
				return err
			}
			return refreshCanonical(tx, key)
		}

		if err := replaceSeasons(tx, title.ID, item); err != nil {
			return err
		}
		if err := replaceGenres(tx, &title, item.Genres); err != nil {
			return err
		}
		titleID = title.ID
		if err := touchItem(tx, src.ID, item.RemoteID, title.ID, hash); err != nil {
			return err
		}
		return refreshCanonical(tx, key)
	})
	if err != nil {
		return "", OutcomeUnchanged, err
	}
	return titleID, outcome, nil
}

func touchItem(tx *gorm.DB, sourceID, remoteID, titleID, hash string) error {
	var item model.Item
	err := tx.Where("source_id = ? AND remote_id = ?", sourceID, remoteID).
		First(&item).Error
	now := time.Now().UTC()
	if errors.Is(err, gorm.ErrRecordNotFound) {
		item = model.Item{
			ID:          uuid.NewString(),
			SourceID:    sourceID,
			RemoteID:    remoteID,
			TitleID:     titleID,
			ContentHash: hash,
			LastSeenAt:  now,
		}
		if err := tx.Create(&item).Error; err != nil {
			return fmt.Errorf("create collect item: %w", err)
		}
		return nil
	}
	if err != nil {
		return fmt.Errorf("load collect item: %w", err)
	}
	if err := tx.Model(&item).Updates(map[string]any{
		"title_id":     titleID,
		"content_hash": hash,
		"last_seen_at": now,
		"removed_at":   nil,
		"updated_at":   now,
	}).Error; err != nil {
		return fmt.Errorf("update collect item: %w", err)
	}
	return nil
}

func replaceSeasons(tx *gorm.DB, titleID string, item *adapter.Title) error {
	var seasonIDs []string
	if err := tx.Model(&model.Season{}).Where("title_id = ?", titleID).
		Pluck("id", &seasonIDs).Error; err != nil {
		return fmt.Errorf("list seasons: %w", err)
	}
	if len(seasonIDs) > 0 {
		if err := tx.Where("season_id IN ?", seasonIDs).Delete(&model.Episode{}).Error; err != nil {
			return fmt.Errorf("delete episodes: %w", err)
		}
	}
	if err := tx.Where("title_id = ?", titleID).Delete(&model.Season{}).Error; err != nil {
		return fmt.Errorf("delete seasons: %w", err)
	}
	if len(item.Episodes) == 0 {
		return nil
	}

	seasons := map[int]*model.Season{}
	numbers := []int{}
	for _, episode := range item.Episodes {
		if episode.URL == "" {
			continue
		}
		number := episode.SeasonNumber
		if number < 1 {
			number = 1
		}
		if _, ok := seasons[number]; !ok {
			seasons[number] = &model.Season{
				ID:      uuid.NewString(),
				TitleID: titleID,
				Number:  number,
				Name:    fmt.Sprintf("Season %d", number),
			}
			numbers = append(numbers, number)
		}
	}
	// Seasons must exist before their episodes: episodes hold the FK.
	for _, number := range numbers {
		if err := tx.Create(seasons[number]).Error; err != nil {
			return fmt.Errorf("create season: %w", err)
		}
	}
	for _, episode := range item.Episodes {
		if episode.URL == "" {
			continue
		}
		number := episode.SeasonNumber
		if number < 1 {
			number = 1
		}
		row := model.Episode{
			ID:        uuid.NewString(),
			SeasonID:  seasons[number].ID,
			Number:    episode.Number,
			Name:      episode.Name,
			StillPath: item.PosterURL,
			VideoURL:  episode.URL,
		}
		if err := tx.Create(&row).Error; err != nil {
			return fmt.Errorf("create episode: %w", err)
		}
	}
	return nil
}

func replaceGenres(tx *gorm.DB, title *model.Title, names []string) error {
	genres := make([]model.Genre, 0, len(names))
	seen := map[string]struct{}{}
	for _, name := range names {
		name = strings.TrimSpace(name)
		slug := slugify(name)
		if name == "" || slug == "" {
			continue
		}
		if _, ok := seen[slug]; ok {
			continue
		}
		seen[slug] = struct{}{}
		genre := model.Genre{Slug: slug}
		if err := tx.Where("slug = ?", slug).
			FirstOrCreate(&genre, model.Genre{Slug: slug, Name: name}).Error; err != nil {
			return fmt.Errorf("resolve genre %q: %w", slug, err)
		}
		genres = append(genres, genre)
	}
	if err := tx.Model(title).Association("Genres").Replace(genres); err != nil {
		return fmt.Errorf("replace genres: %w", err)
	}
	return nil
}

// MarkMissing tombstones titles that a full scan did not see.
func (s *Store) MarkMissing(ctx context.Context, sourceID string, since time.Time) (int, error) {
	var items []model.Item
	if err := s.db.WithContext(ctx).
		Where("source_id = ? AND last_seen_at < ? AND removed_at IS NULL", sourceID, since).
		Find(&items).Error; err != nil {
		return 0, fmt.Errorf("list missing items: %w", err)
	}
	if len(items) == 0 {
		return 0, nil
	}
	now := time.Now().UTC()
	itemIDs := make([]string, 0, len(items))
	titleIDs := make([]string, 0, len(items))
	for _, item := range items {
		itemIDs = append(itemIDs, item.ID)
		titleIDs = append(titleIDs, item.TitleID)
	}
	err := s.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		var keys []string
		if err := tx.Model(&model.Title{}).Where("id IN ? AND work_key <> ?", titleIDs, "").
			Distinct().Pluck("work_key", &keys).Error; err != nil {
			return fmt.Errorf("list tombstoned work keys: %w", err)
		}
		if err := tx.Model(&model.Item{}).Where("id IN ?", itemIDs).
			Update("removed_at", now).Error; err != nil {
			return err
		}
		if err := tx.Model(&model.Title{}).Where("id IN ?", titleIDs).
			Update("removed_at", now).Error; err != nil {
			return err
		}
		// A tombstoned offer may have been the canonical one; hand the badge to
		// a surviving source so the work stays visible.
		for _, key := range keys {
			if err := refreshCanonical(tx, key); err != nil {
				return err
			}
		}
		return nil
	})
	if err != nil {
		return 0, fmt.Errorf("tombstone missing titles: %w", err)
	}
	return len(items), nil
}

// refreshCanonical marks exactly one live, enabled rendition of a work as the
// canonical row. The oldest row wins so browse ids stay stable as sources are
// added; when it disappears the next oldest takes over.
func refreshCanonical(tx *gorm.DB, workKey string) error {
	if workKey == "" {
		return nil
	}
	if err := tx.Model(&model.Title{}).
		Where("work_key = ?", workKey).
		Update("canonical", false).Error; err != nil {
		return fmt.Errorf("clear canonical title: %w", err)
	}
	var ids []string
	if err := tx.Model(&model.Title{}).
		Where("work_key = ?", workKey).
		Where("removed_at IS NULL").
		Where(`source_id IS NULL OR EXISTS (
			SELECT 1 FROM content_sources cs
			WHERE cs.id = titles.source_id AND cs.enabled
		)`).
		Order("created_at ASC, id ASC").
		Limit(1).
		Pluck("id", &ids).Error; err != nil {
		return fmt.Errorf("pick canonical title: %w", err)
	}
	if len(ids) == 0 {
		return nil
	}
	if err := tx.Model(&model.Title{}).
		Where("id = ?", ids[0]).
		Update("canonical", true).Error; err != nil {
		return fmt.Errorf("set canonical title: %w", err)
	}
	return nil
}

// SetSourceTypes caches the provider's category list on the source row so the
// API can render the scope selector without calling the provider.
func (s *Store) SetSourceTypes(ctx context.Context, sourceID, raw string) error {
	if strings.TrimSpace(raw) == "" {
		raw = "[]"
	}
	if err := s.db.WithContext(ctx).Model(&model.Source{}).
		Where("id = ?", sourceID).
		Update("types", gorm.Expr("?::jsonb", raw)).Error; err != nil {
		return fmt.Errorf("store source categories: %w", err)
	}
	return nil
}

// RecordSync stores the outcome of a run on the provider row.
func (s *Store) RecordSync(ctx context.Context, sourceID, note string) error {
	now := time.Now().UTC()
	if err := s.db.WithContext(ctx).Model(&model.Source{}).Where("id = ?", sourceID).
		Updates(map[string]any{
			"last_synced_at": now,
			"last_sync_note": truncate(note, 400),
		}).Error; err != nil {
		return fmt.Errorf("record sync: %w", err)
	}
	return nil
}

// workKeyOf derives the cross-source identity of a provider title. Year is
// only included when the provider reports it, so a movie keeps one identity
// even when another source omits the year.
func workKeyOf(item *adapter.Title) string {
	name := normaliseTitleName(item.Name)
	if name == "" {
		return ""
	}
	kind := strings.ToLower(strings.TrimSpace(item.Kind))
	if item.Year > 0 {
		return fmt.Sprintf("%s|%d|%s", name, item.Year, kind)
	}
	return fmt.Sprintf("%s|%s", name, kind)
}

var (
	parenthesisedYear = regexp.MustCompile(`\s*[\(（]\s*(?:19|20)\d{2}\s*[\)）]$`)
	trailingYear      = regexp.MustCompile(`\s+(?:19|20)\d{2}$`)
)

func normaliseTitleName(name string) string {
	name = strings.ToLower(strings.Join(strings.Fields(name), " "))
	name = parenthesisedYear.ReplaceAllString(name, "")
	name = trailingYear.ReplaceAllString(name, "")
	return strings.TrimSpace(name)
}

// slugFor builds a stable, unique catalogue slug for a provider row.
func slugFor(sourceSlug, remoteID string) string {
	slug := slugify(sourceSlug + "-" + remoteID)
	if slug == "" {
		slug = "item-" + remoteID
	}
	if len(slug) > 160 {
		slug = strings.Trim(slug[:160], "-")
	}
	return slug
}

func slugify(raw string) string {
	raw = strings.TrimSpace(strings.ToLower(raw))
	var b strings.Builder
	lastDash := false
	for _, r := range raw {
		switch {
		case r >= 'a' && r <= 'z', r >= '0' && r <= '9':
			b.WriteRune(r)
			lastDash = false
		case r > 127:
			b.WriteRune(r)
			lastDash = false
		default:
			if !lastDash && b.Len() > 0 {
				b.WriteByte('-')
				lastDash = true
			}
		}
	}
	return strings.Trim(b.String(), "-")
}

// FindItem loads the change-detection row for a provider entry.
func (s *Store) FindItem(ctx context.Context, sourceID, remoteID string) (*model.Item, error) {
	var item model.Item
	if err := s.db.WithContext(ctx).
		Where("source_id = ? AND remote_id = ?", sourceID, remoteID).
		First(&item).Error; err != nil {
		return nil, err
	}
	return &item, nil
}

// AddMediaHosts merges hosts learned from imported renditions into the
// provider's playback allowlist.
func (s *Store) AddMediaHosts(ctx context.Context, sourceID string, hosts []string) error {
	source, err := s.GetSource(ctx, sourceID)
	if err != nil {
		return err
	}
	known := make(map[string]struct{}, len(source.MediaHosts))
	merged := make([]string, 0, len(source.MediaHosts)+len(hosts))
	for _, host := range source.MediaHosts {
		host = strings.ToLower(strings.TrimSpace(host))
		if host == "" {
			continue
		}
		if _, ok := known[host]; ok {
			continue
		}
		known[host] = struct{}{}
		merged = append(merged, host)
	}
	added := false
	for _, host := range hosts {
		host = strings.ToLower(strings.TrimSpace(host))
		if host == "" {
			continue
		}
		if _, ok := known[host]; ok {
			continue
		}
		known[host] = struct{}{}
		merged = append(merged, host)
		added = true
	}
	if !added {
		return nil
	}
	source.MediaHosts = merged
	if err := s.db.WithContext(ctx).Model(&model.Source{}).Where("id = ?", sourceID).
		Update("media_hosts", pq.StringArray(merged)).Error; err != nil {
		return fmt.Errorf("update media hosts: %w", err)
	}
	return nil
}
