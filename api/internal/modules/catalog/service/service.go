// Package service contains catalog use cases and maps persistence entities to
// stable API contracts. HTTP and other feature modules only see this package's
// contract types, never GORM models.
package service

import (
	"context"
	"fmt"
	"strings"

	"github.com/pagefau1t/speedvideo/api/internal/modules/catalog/contracts"
	"github.com/pagefau1t/speedvideo/api/internal/modules/catalog/domain"
	"github.com/pagefau1t/speedvideo/api/internal/modules/catalog/repository"
	"github.com/pagefau1t/speedvideo/api/internal/platform/apperr"
)

// ViewerState is the small slice of per-profile state the catalog needs. The
// library module implements it; catalog does not depend on the library.
type ViewerState interface {
	ProgressFor(ctx context.Context, profileID, titleID string) (*contracts.Progress, error)
	IsInWatchlist(ctx context.Context, profileID, titleID string) (bool, error)
}

// BrowseFilter is the transport-facing browse input.
type BrowseFilter struct {
	Kind     string
	Genre    string
	Sort     string
	Page     int
	PageSize int
}

// Page is a paginated list of title cards.
type Page struct {
	Items    []contracts.TitleCard `json:"items"`
	Page     int                   `json:"page"`
	PageSize int                   `json:"page_size"`
	Total    int64                 `json:"total"`
	HasMore  bool                  `json:"has_more"`
}

// Repository is the catalog persistence port. It is satisfied by the GORM
// repository and replaced by fakes in unit tests.
type Repository interface {
	GetByID(ctx context.Context, id string, kids bool) (*domain.Title, error)
	Featured(ctx context.Context, kids bool) (*domain.Title, error)
	Popular(ctx context.Context, kids bool, limit int) ([]domain.Title, error)
	NewReleases(ctx context.Context, kids bool, limit int) ([]domain.Title, error)
	ByGenre(ctx context.Context, genreSlug string, kids bool, limit int) ([]domain.Title, error)
	List(
		ctx context.Context,
		filter repository.TitleFilter,
		kids bool,
	) ([]domain.Title, int64, error)
	Search(ctx context.Context, query, kind string, kids bool, limit int) ([]domain.Title, error)
	Similar(ctx context.Context, title *domain.Title, kids bool, limit int) ([]domain.Title, error)
	CardsByIDs(ctx context.Context, ids []string, kids bool) ([]domain.Title, error)
	Offers(ctx context.Context, title *domain.Title) ([]repository.Offer, error)
	RefreshCanonicalForSource(ctx context.Context, sourceID string) error
	Genres(ctx context.Context) ([]domain.Genre, error)
}

// Service exposes catalog use cases.
type Service struct {
	repo   Repository
	viewer ViewerState
}

// New builds the catalog service. viewer may be nil in tests where personalised
// state is irrelevant.
func New(repo Repository, viewer ViewerState) *Service {
	return &Service{repo: repo, viewer: viewer}
}

// SetViewer attaches the library-backed viewer state after both modules have
// been constructed (they are wired during application startup).
func (s *Service) SetViewer(viewer ViewerState) {
	s.viewer = viewer
}

// Featured returns the billboard title, falling back to the most popular title
// when no title is explicitly featured.
func (s *Service) Featured(ctx context.Context, kids bool) (*contracts.TitleCard, error) {
	title, err := s.repo.Featured(ctx, kids)
	if err != nil {
		if apperr.IsKind(err, apperr.KindNotFound) {
			popular, popErr := s.repo.Popular(ctx, kids, 1)
			if popErr != nil || len(popular) == 0 {
				return nil, apperr.New(apperr.KindNotFound, "catalog is empty")
			}
			card := s.card(popular[0])
			return &card, nil
		}
		return nil, err
	}
	card := s.card(*title)
	return &card, nil
}

// Popular returns trending titles.
func (s *Service) Popular(
	ctx context.Context,
	kids bool,
	limit int,
) ([]contracts.TitleCard, error) {
	return s.cards(s.repo.Popular(ctx, kids, limit))
}

// NewReleases returns recently released titles.
func (s *Service) NewReleases(
	ctx context.Context,
	kids bool,
	limit int,
) ([]contracts.TitleCard, error) {
	return s.cards(s.repo.NewReleases(ctx, kids, limit))
}

// ByGenre returns titles in a genre.
func (s *Service) ByGenre(
	ctx context.Context,
	genreSlug string,
	kids bool,
	limit int,
) ([]contracts.TitleCard, error) {
	return s.cards(s.repo.ByGenre(ctx, genreSlug, kids, limit))
}

// RefreshSourceCanonical re-elects canonical rows after a source changes state.
func (s *Service) RefreshSourceCanonical(ctx context.Context, sourceID string) error {
	return s.repo.RefreshCanonicalForSource(ctx, sourceID)
}

// Genres lists catalogue categories.
func (s *Service) Genres(ctx context.Context) ([]contracts.Genre, error) {
	genres, err := s.repo.Genres(ctx)
	if err != nil {
		return nil, err
	}
	out := make([]contracts.Genre, 0, len(genres))
	for _, genre := range genres {
		out = append(out, contracts.Genre{Slug: genre.Slug, Name: genre.Name})
	}
	return out, nil
}

// Browse returns a paginated catalogue query.
func (s *Service) Browse(ctx context.Context, filter BrowseFilter, kids bool) (*Page, error) {
	if filter.Page < 1 {
		filter.Page = 1
	}
	if filter.PageSize < 1 {
		filter.PageSize = 20
	}
	if filter.PageSize > 50 {
		filter.PageSize = 50
	}
	if filter.Kind != "" && filter.Kind != domain.KindMovie && filter.Kind != domain.KindSeries {
		return nil, apperr.New(apperr.KindValidation, "kind must be movie or series")
	}
	titles, total, err := s.repo.List(ctx, repository.TitleFilter{
		Kind:     filter.Kind,
		Genre:    filter.Genre,
		Sort:     filter.Sort,
		Page:     filter.Page,
		PageSize: filter.PageSize,
	}, kids)
	if err != nil {
		return nil, err
	}
	items, err := s.cards(titles, nil)
	if err != nil {
		return nil, err
	}
	return &Page{
		Items:    items,
		Page:     filter.Page,
		PageSize: filter.PageSize,
		Total:    total,
		HasMore:  int64(filter.Page*filter.PageSize) < total,
	}, nil
}

// Search performs a catalogue search, optionally restricted to movies or
// series so the client's type filter is applied server-side.
func (s *Service) Search(
	ctx context.Context,
	query, kind string,
	kids bool,
	limit int,
) ([]contracts.TitleCard, error) {
	query = strings.TrimSpace(query)
	if len([]rune(query)) < 2 {
		return nil, apperr.New(apperr.KindValidation, "search query must be at least 2 characters")
	}
	kind = strings.TrimSpace(kind)
	if kind != "" && kind != domain.KindMovie && kind != domain.KindSeries {
		return nil, apperr.New(apperr.KindValidation, "kind must be movie or series")
	}
	if limit < 1 || limit > 50 {
		limit = 30
	}
	titles, err := s.repo.Search(ctx, query, kind, kids, limit)
	if err != nil {
		return nil, err
	}
	return s.cards(titles, nil)
}

// Detail returns a full title page, including personalised state when a profile
// is available.
func (s *Service) Detail(
	ctx context.Context,
	titleID, profileID string,
	kids bool,
) (*contracts.TitleDetail, error) {
	title, err := s.repo.GetByID(ctx, titleID, kids)
	if err != nil {
		return nil, err
	}
	card := s.card(*title)
	detail := &contracts.TitleDetail{
		TitleCard:    card,
		OriginalName: title.OriginalName,
		Synopsis:     title.Synopsis,
		Tagline:      title.Tagline,
		Director:     title.Director,
		Country:      title.Country,
		Cast:         nonNil(title.Cast),
		TrailerURL:   title.TrailerURL,
	}
	for _, season := range title.Seasons {
		seasonOut := contracts.Season{
			ID:       season.ID,
			Number:   season.Number,
			Name:     season.Name,
			Episodes: make([]contracts.Episode, 0, len(season.Episodes)),
		}
		for _, episode := range season.Episodes {
			seasonOut.Episodes = append(seasonOut.Episodes, contracts.Episode{
				ID:             episode.ID,
				Number:         episode.Number,
				SeasonNumber:   season.Number,
				Name:           episode.Name,
				Synopsis:       episode.Synopsis,
				RuntimeMinutes: episode.RuntimeMinutes,
				StillPath:      episode.StillPath,
			})
		}
		detail.Seasons = append(detail.Seasons, seasonOut)
	}

	offers, err := s.repo.Offers(ctx, title)
	if err != nil {
		return nil, err
	}
	detail.Offers = make([]contracts.TitleOffer, 0, len(offers))
	for _, offer := range offers {
		detail.Offers = append(detail.Offers, contracts.TitleOffer{
			TitleID:      offer.TitleID,
			SourceID:     offer.SourceID,
			SourceName:   offer.SourceName,
			EpisodeCount: offer.EpisodeCount,
			Selected:     offer.TitleID == title.ID,
		})
	}

	if s.viewer != nil && profileID != "" {
		progress, err := s.viewer.ProgressFor(ctx, profileID, titleID)
		if err != nil {
			return nil, fmt.Errorf("load viewer progress: %w", err)
		}
		detail.Resume = progress
		detail.Progress = progress
		inWatchlist, err := s.viewer.IsInWatchlist(ctx, profileID, titleID)
		if err != nil {
			return nil, fmt.Errorf("load watchlist state: %w", err)
		}
		detail.InWatchlist = inWatchlist
	}
	return detail, nil
}

// Similar returns titles sharing genres with the given title.
func (s *Service) Similar(
	ctx context.Context,
	titleID string,
	kids bool,
	limit int,
) ([]contracts.TitleCard, error) {
	title, err := s.repo.GetByID(ctx, titleID, kids)
	if err != nil {
		return nil, err
	}
	if limit < 1 || limit > 30 {
		limit = 12
	}
	similar, err := s.repo.Similar(ctx, title, kids, limit)
	if err != nil {
		return nil, err
	}
	return s.cards(similar, nil)
}

// CardsByIDs returns cards keyed by title id. Unknown and age-restricted ids
// are omitted.
func (s *Service) CardsByIDs(
	ctx context.Context,
	ids []string,
	kids bool,
) (map[string]contracts.TitleCard, error) {
	titles, err := s.repo.CardsByIDs(ctx, ids, kids)
	if err != nil {
		return nil, err
	}
	cards := make(map[string]contracts.TitleCard, len(titles))
	for _, title := range titles {
		cards[title.ID] = s.card(title)
	}
	return cards, nil
}

// mediaTarget is a resolved title/episode pair shared by playback and download.
type mediaTarget struct {
	title   *domain.Title
	episode *domain.Episode
	ref     *contracts.EpisodeRef
}

func (s *Service) resolveTarget(
	ctx context.Context,
	titleID, episodeID string,
	kids bool,
) (*mediaTarget, error) {
	title, err := s.repo.GetByID(ctx, titleID, kids)
	if err != nil {
		return nil, err
	}
	target := &mediaTarget{title: title}
	if title.Kind != domain.KindSeries {
		return target, nil
	}

	var chosen *domain.Episode
	chosenSeason := 0
	for _, season := range title.Seasons {
		for _, episode := range season.Episodes {
			if episodeID != "" && episode.ID == episodeID {
				matched := episode
				chosen = &matched
				chosenSeason = season.Number
				break
			}
		}
		if chosen != nil {
			break
		}
	}
	if chosen == nil && episodeID != "" {
		return nil, apperr.New(apperr.KindNotFound, "episode not found")
	}
	if chosen == nil && len(title.Seasons) > 0 && len(title.Seasons[0].Episodes) > 0 {
		first := title.Seasons[0].Episodes[0]
		chosen = &first
		chosenSeason = title.Seasons[0].Number
	}
	if chosen != nil {
		target.episode = chosen
		target.ref = &contracts.EpisodeRef{
			ID:             chosen.ID,
			Number:         chosen.Number,
			SeasonNumber:   chosenSeason,
			Name:           chosen.Name,
			RuntimeMinutes: chosen.RuntimeMinutes,
		}
	}
	return target, nil
}

// PlaybackSource resolves the upstream stream for a title or episode.
func (s *Service) PlaybackSource(
	ctx context.Context,
	titleID, episodeID string,
	kids bool,
) (*contracts.PlaybackSource, error) {
	target, err := s.resolveTarget(ctx, titleID, episodeID, kids)
	if err != nil {
		return nil, err
	}
	title := target.title
	source := &contracts.PlaybackSource{
		TitleID:        title.ID,
		TitleName:      title.Name,
		VideoURL:       title.VideoURL,
		RuntimeSeconds: title.RuntimeMinutes * 60,
		PosterPath:     title.PosterPath,
		BackdropPath:   title.BackdropPath,
		Episode:        target.ref,
	}
	if title.SourceID != nil {
		source.SourceID = *title.SourceID
	}
	if target.episode != nil {
		if target.episode.VideoURL != "" {
			source.VideoURL = target.episode.VideoURL
		}
		if target.episode.RuntimeMinutes > 0 {
			source.RuntimeSeconds = target.episode.RuntimeMinutes * 60
		}
	}
	if source.VideoURL == "" {
		return nil, apperr.New(apperr.KindNotFound, "playback is not available for this title")
	}
	return source, nil
}

// DownloadSource resolves the offline rendition for a title or episode.
// Titles without a downloadable rendition are reported as not found rather
// than silently falling back to the stream, so clients can explain why a
// download is unavailable.
func (s *Service) DownloadSource(
	ctx context.Context,
	titleID, episodeID string,
	kids bool,
) (*contracts.DownloadSource, error) {
	target, err := s.resolveTarget(ctx, titleID, episodeID, kids)
	if err != nil {
		return nil, err
	}
	title := target.title
	fileName := title.Slug + ".mp4"
	fileURL := title.DownloadURL
	runtime := title.RuntimeMinutes * 60
	if target.ref != nil {
		fileName = fmt.Sprintf(
			"%s-s%02de%02d.mp4",
			title.Slug,
			target.ref.SeasonNumber,
			target.ref.Number,
		)
	}
	if target.episode != nil {
		if target.episode.DownloadURL != "" {
			fileURL = target.episode.DownloadURL
		}
		if target.episode.RuntimeMinutes > 0 {
			runtime = target.episode.RuntimeMinutes * 60
		}
	}
	if fileURL == "" {
		return nil, apperr.New(apperr.KindNotFound, "download is not available for this title")
	}
	return &contracts.DownloadSource{
		TitleID:        title.ID,
		TitleName:      title.Name,
		FileName:       fileName,
		FileURL:        fileURL,
		RuntimeSeconds: runtime,
		PosterPath:     title.PosterPath,
		BackdropPath:   title.BackdropPath,
		Episode:        target.ref,
	}, nil
}

func (s *Service) cards(titles []domain.Title, err error) ([]contracts.TitleCard, error) {
	if err != nil {
		return nil, err
	}
	cards := make([]contracts.TitleCard, 0, len(titles))
	for _, title := range titles {
		cards = append(cards, s.card(title))
	}
	return cards, nil
}

func (s *Service) card(title domain.Title) contracts.TitleCard {
	genres := make([]contracts.Genre, 0, len(title.Genres))
	for _, genre := range title.Genres {
		genres = append(genres, contracts.Genre{Slug: genre.Slug, Name: genre.Name})
	}
	return contracts.TitleCard{
		ID:             title.ID,
		Slug:           title.Slug,
		Name:           title.Name,
		Kind:           title.Kind,
		ReleaseYear:    title.ReleaseYear,
		MaturityRating: title.MaturityRating,
		RuntimeMinutes: title.RuntimeMinutes,
		PosterPath:     title.PosterPath,
		BackdropPath:   title.BackdropPath,
		LogoPath:       title.LogoPath,
		MatchPercent:   title.MatchPercent,
		Badges:         nonNil(title.Badges),
		Genres:         genres,
	}
}

func nonNil(values []string) []string {
	if values == nil {
		return []string{}
	}
	return values
}

// slugify converts a display label into a URL-safe genre slug.
func slugify(value string) string {
	var b strings.Builder
	lastDash := false
	for _, r := range strings.ToLower(strings.TrimSpace(value)) {
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
