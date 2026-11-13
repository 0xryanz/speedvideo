// Package repository implements catalog persistence with GORM. All queries are
// expressed through GORM's builder; the module contains no hand-written SQL.
package repository

import (
	"context"
	"errors"
	"fmt"
	"strings"

	"gorm.io/gorm"

	"github.com/pagefau1t/speedvideo/api/internal/modules/catalog/domain"
	"github.com/pagefau1t/speedvideo/api/internal/platform/apperr"
)

// TitleFilter describes a browse query.
type TitleFilter struct {
	Kind     string
	Genre    string
	Sort     string
	Page     int
	PageSize int
}

// visibleTitle keeps tombstones and content from disabled sources out of every
// read path. A title with no source is operator-curated and always visible.
const visibleTitle = `titles.removed_at IS NULL AND (
	titles.source_id IS NULL OR EXISTS (
		SELECT 1 FROM content_sources cs
		WHERE cs.id = titles.source_id AND cs.enabled
	)
)`

// browsableTitle additionally collapses a work offered by several sources into
// its canonical row, so feeds and search never show the same film twice.
const browsableTitle = visibleTitle + ` AND titles.canonical`

// Repository is the catalog persistence gateway.
type Repository struct {
	db *gorm.DB
}

// New builds a catalog repository.
func New(db *gorm.DB) *Repository {
	return &Repository{db: db}
}

// GetByID loads a title with genres, seasons and episodes.
func (r *Repository) GetByID(ctx context.Context, id string, kids bool) (*domain.Title, error) {
	query := r.preloadAll(r.db.WithContext(ctx)).Where("titles.id = ?", id)
	// Detail is reachable for every offer, not only the canonical one: the
	// viewer picks a source and loads that row.
	query = query.Where(visibleTitle)
	if kids {
		query = query.Where("maturity_rating IN ?", domain.KidsSafeRatings)
	}
	var title domain.Title
	if err := query.First(&title).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, apperr.New(apperr.KindNotFound, "title not found")
		}
		return nil, fmt.Errorf("load title: %w", err)
	}
	return &title, nil
}

// Featured returns the current billboard title.
func (r *Repository) Featured(ctx context.Context, kids bool) (*domain.Title, error) {
	var title domain.Title
	query := r.preloadGenres(r.db.WithContext(ctx)).
		Where("titles.featured = ?", true).
		Where(browsableTitle)
	if kids {
		query = query.Where("maturity_rating IN ?", domain.KidsSafeRatings)
	}
	if err := query.Order("popularity DESC").First(&title).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, apperr.New(apperr.KindNotFound, "no featured title")
		}
		return nil, fmt.Errorf("load featured title: %w", err)
	}
	return &title, nil
}

// Popular returns the most popular titles.
func (r *Repository) Popular(ctx context.Context, kids bool, limit int) ([]domain.Title, error) {
	return r.list(ctx, kids, limit, "popularity DESC, release_year DESC")
}

// NewReleases returns the most recently released titles.
func (r *Repository) NewReleases(
	ctx context.Context,
	kids bool,
	limit int,
) ([]domain.Title, error) {
	return r.list(ctx, kids, limit, "release_year DESC, popularity DESC")
}

// ByGenre returns popular titles within a genre slug.
func (r *Repository) ByGenre(
	ctx context.Context,
	genreSlug string,
	kids bool,
	limit int,
) ([]domain.Title, error) {
	var titles []domain.Title
	query := r.preloadGenres(r.db.WithContext(ctx)).
		Joins("JOIN title_genres ON title_genres.title_id = titles.id").
		Joins("JOIN genres ON genres.id = title_genres.genre_id").
		Where("genres.slug = ?", genreSlug).
		Where(browsableTitle)
	if kids {
		query = query.Where("titles.maturity_rating IN ?", domain.KidsSafeRatings)
	}
	if err := query.Order("titles.popularity DESC").Group("titles.id").Limit(limit).Find(&titles).Error; err != nil {
		return nil, fmt.Errorf("load genre titles: %w", err)
	}
	return titles, nil
}

// List returns a filtered, paginated catalogue page.
func (r *Repository) List(
	ctx context.Context,
	filter TitleFilter,
	kids bool,
) ([]domain.Title, int64, error) {
	countQuery := r.filtered(r.db.WithContext(ctx).Model(&domain.Title{}), filter, kids)
	var total int64
	if err := countQuery.Distinct("titles.id").Count(&total).Error; err != nil {
		return nil, 0, fmt.Errorf("count titles: %w", err)
	}

	order := "titles.popularity DESC"
	switch filter.Sort {
	case "newest":
		order = "titles.release_year DESC, titles.popularity DESC"
	case "name":
		order = "titles.name ASC"
	case "rating":
		order = "titles.match_percent DESC, titles.popularity DESC"
	}
	offset := (filter.Page - 1) * filter.PageSize
	var titles []domain.Title
	listQuery := r.filtered(r.db.WithContext(ctx).Model(&domain.Title{}), filter, kids)
	if err := r.preloadGenres(listQuery).Order(order).
		Offset(offset).Limit(filter.PageSize).
		Find(&titles).Error; err != nil {
		return nil, 0, fmt.Errorf("list titles: %w", err)
	}
	return titles, total, nil
}

// Search performs a case-insensitive search across titles, synopses and
// genres, ordered by popularity. A production deployment can swap this
// implementation for an OpenSearch-backed adapter without touching callers.
func (r *Repository) Search(
	ctx context.Context,
	query, kind string,
	kids bool,
	limit int,
) ([]domain.Title, error) {
	pattern := "%" + strings.TrimSpace(query) + "%"
	db := r.preloadGenres(r.db.WithContext(ctx)).
		Joins("LEFT JOIN title_genres ON title_genres.title_id = titles.id").
		Joins("LEFT JOIN genres ON genres.id = title_genres.genre_id").
		Where("titles.name ILIKE ? OR titles.original_name ILIKE ? OR titles.synopsis ILIKE ? OR genres.name ILIKE ?", pattern, pattern, pattern, pattern).
		Where(browsableTitle).
		Distinct("titles.*")
	if kind != "" {
		db = db.Where("titles.kind = ?", kind)
	}
	if kids {
		db = db.Where("titles.maturity_rating IN ?", domain.KidsSafeRatings)
	}
	var titles []domain.Title
	if err := db.Order("titles.popularity DESC").Limit(limit).Find(&titles).Error; err != nil {
		return nil, fmt.Errorf("search titles: %w", err)
	}
	return titles, nil
}

// Similar returns titles sharing genres with the given title.
func (r *Repository) Similar(
	ctx context.Context,
	title *domain.Title,
	kids bool,
	limit int,
) ([]domain.Title, error) {
	if len(title.Genres) == 0 {
		return []domain.Title{}, nil
	}
	slugs := make([]string, 0, len(title.Genres))
	for _, genre := range title.Genres {
		slugs = append(slugs, genre.Slug)
	}
	query := r.preloadGenres(r.db.WithContext(ctx)).
		Joins("JOIN title_genres ON title_genres.title_id = titles.id").
		Joins("JOIN genres ON genres.id = title_genres.genre_id").
		Where("genres.slug IN ?", slugs).
		Where("titles.id <> ?", title.ID).
		Where(browsableTitle)
	if kids {
		query = query.Where("titles.maturity_rating IN ?", domain.KidsSafeRatings)
	}
	var titles []domain.Title
	if err := query.Group("titles.id").
		Order("COUNT(title_genres.genre_id) DESC, titles.popularity DESC").
		Limit(limit).
		Find(&titles).Error; err != nil {
		return nil, fmt.Errorf("load similar titles: %w", err)
	}
	return titles, nil
}

// CardsByIDs loads a set of titles with genres, skipping ids that do not exist.
func (r *Repository) CardsByIDs(
	ctx context.Context,
	ids []string,
	kids bool,
) ([]domain.Title, error) {
	if len(ids) == 0 {
		return []domain.Title{}, nil
	}
	query := r.preloadGenres(r.db.WithContext(ctx)).
		Where("titles.id IN ?", ids).
		Where(visibleTitle)
	if kids {
		query = query.Where("maturity_rating IN ?", domain.KidsSafeRatings)
	}
	var titles []domain.Title
	if err := query.Find(&titles).Error; err != nil {
		return nil, fmt.Errorf("load titles by ids: %w", err)
	}
	return titles, nil
}

// Offer is one source's rendition of a work. Several offers can share a work
// key: the same film licensed from more than one provider.
type Offer struct {
	TitleID      string
	SourceID     string
	SourceName   string
	EpisodeCount int
}

// RefreshCanonicalForSource re-elects the canonical row for every work a
// source offers. Called when a source is enabled, disabled or deleted so the
// catalogue never keeps a hidden row as the only entry of a work.
func (r *Repository) RefreshCanonicalForSource(ctx context.Context, sourceID string) error {
	var keys []string
	if err := r.db.WithContext(ctx).Model(&domain.Title{}).
		Where("source_id = ? AND work_key <> ?", sourceID, "").
		Distinct().Pluck("work_key", &keys).Error; err != nil {
		return fmt.Errorf("list source work keys: %w", err)
	}
	for _, key := range keys {
		if err := r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
			return refreshCanonical(tx, key)
		}); err != nil {
			return err
		}
	}
	return nil
}

// refreshCanonical marks exactly one live, enabled rendition of a work as the
// canonical row. The oldest row wins so browse ids stay stable; when it
// disappears the next oldest takes over.
func refreshCanonical(tx *gorm.DB, workKey string) error {
	if err := tx.Model(&domain.Title{}).
		Where("work_key = ?", workKey).
		Update("canonical", false).Error; err != nil {
		return fmt.Errorf("clear canonical title: %w", err)
	}
	var ids []string
	if err := tx.Model(&domain.Title{}).
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
	if err := tx.Model(&domain.Title{}).
		Where("id = ?", ids[0]).
		Update("canonical", true).Error; err != nil {
		return fmt.Errorf("set canonical title: %w", err)
	}
	return nil
}

// Offers lists the live renditions of the work behind title, canonical first.
// A title without a work key is its own only offer.
func (r *Repository) Offers(ctx context.Context, title *domain.Title) ([]Offer, error) {
	if title.WorkKey == "" {
		offer := Offer{TitleID: title.ID, EpisodeCount: len(allEpisodes(title))}
		if title.SourceID != nil {
			offer.SourceID = *title.SourceID
			var name string
			if err := r.db.WithContext(ctx).Raw(
				"SELECT COALESCE(name, '') FROM content_sources WHERE id = ?", *title.SourceID,
			).Scan(&name).Error; err == nil {
				offer.SourceName = name
			}
		}
		return []Offer{offer}, nil
	}

	var offers []Offer
	err := r.db.WithContext(ctx).
		Table("titles").
		Select(`titles.id AS title_id,
			COALESCE(titles.source_id::text, '') AS source_id,
			COALESCE(cs.name, '') AS source_name,
			(SELECT count(*) FROM episodes e
				JOIN seasons s ON s.id = e.season_id
				WHERE s.title_id = titles.id) AS episode_count`).
		Joins("LEFT JOIN content_sources cs ON cs.id = titles.source_id").
		Where("titles.work_key = ?", title.WorkKey).
		Where("titles.removed_at IS NULL").
		Where("titles.source_id IS NULL OR cs.enabled").
		Order("titles.canonical DESC, cs.name ASC, titles.created_at ASC").
		Scan(&offers).Error
	if err != nil {
		return nil, fmt.Errorf("list title offers: %w", err)
	}
	return offers, nil
}

func allEpisodes(title *domain.Title) []domain.Episode {
	var episodes []domain.Episode
	for _, season := range title.Seasons {
		episodes = append(episodes, season.Episodes...)
	}
	return episodes
}

// Genres lists the genres that still have a visible title, alphabetically.
// Genres left behind by removed or disabled sources are not advertised.
func (r *Repository) Genres(ctx context.Context) ([]domain.Genre, error) {
	var genres []domain.Genre
	err := r.db.WithContext(ctx).
		Joins("JOIN title_genres tg ON tg.genre_id = genres.id").
		Joins("JOIN titles ON titles.id = tg.title_id").
		Where(browsableTitle).
		Distinct("genres.*").
		Order("genres.name ASC").
		Find(&genres).Error
	if err != nil {
		return nil, fmt.Errorf("list genres: %w", err)
	}
	return genres, nil
}

func (r *Repository) list(
	ctx context.Context,
	kids bool,
	limit int,
	order string,
) ([]domain.Title, error) {
	query := r.preloadGenres(r.db.WithContext(ctx)).
		Where(browsableTitle)
	if kids {
		query = query.Where("maturity_rating IN ?", domain.KidsSafeRatings)
	}
	var titles []domain.Title
	if err := query.Order(order).Limit(limit).Find(&titles).Error; err != nil {
		return nil, fmt.Errorf("list titles: %w", err)
	}
	return titles, nil
}

func (r *Repository) preloadGenres(db *gorm.DB) *gorm.DB {
	return db.Preload("Genres", func(tx *gorm.DB) *gorm.DB { return tx.Order("genres.name ASC") })
}

func (r *Repository) filtered(query *gorm.DB, filter TitleFilter, kids bool) *gorm.DB {
	query = query.Where(browsableTitle)
	if kids {
		query = query.Where("titles.maturity_rating IN ?", domain.KidsSafeRatings)
	}
	if filter.Kind != "" {
		query = query.Where("titles.kind = ?", filter.Kind)
	}
	if filter.Genre != "" {
		query = query.Joins("JOIN title_genres ON title_genres.title_id = titles.id").
			Joins("JOIN genres ON genres.id = title_genres.genre_id").
			Where("genres.slug = ?", filter.Genre)
	}
	return query
}

func (r *Repository) preloadAll(db *gorm.DB) *gorm.DB {
	return r.preloadGenres(db).
		Preload("Seasons", func(tx *gorm.DB) *gorm.DB { return tx.Order("seasons.number ASC") }).
		Preload("Seasons.Episodes", func(tx *gorm.DB) *gorm.DB { return tx.Order("episodes.number ASC") })
}
