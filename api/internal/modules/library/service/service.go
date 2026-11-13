// Package service contains library use cases: watch list management and
// resumable playback state. It enriches ids with catalog contracts through a
// narrow reader interface, keeping the two modules decoupled.
package service

import (
	"context"

	"github.com/pagefau1t/speedvideo/api/internal/modules/catalog/contracts"
	"github.com/pagefau1t/speedvideo/api/internal/modules/library/domain"
	"github.com/pagefau1t/speedvideo/api/internal/platform/apperr"
)

// TitleReader is the catalog capability required by the library. The catalog
// service satisfies it.
type TitleReader interface {
	CardsByIDs(ctx context.Context, ids []string, kids bool) (map[string]contracts.TitleCard, error)
}

// Repository is the library persistence port.
type Repository interface {
	ListWatchlist(ctx context.Context, profileID string) ([]string, error)
	AddToWatchlist(ctx context.Context, profileID, titleID string) error
	RemoveFromWatchlist(ctx context.Context, profileID, titleID string) error
	IsInWatchlist(ctx context.Context, profileID, titleID string) (bool, error)
	GetProgress(ctx context.Context, profileID, titleID string) (*domain.Progress, error)
	UpsertProgress(ctx context.Context, progress *domain.Progress) error
	ContinueWatching(ctx context.Context, profileID string, limit int) ([]domain.Progress, error)
	DeleteProfileState(ctx context.Context, profileID string) error
}

// Service exposes library use cases.
type Service struct {
	repo   Repository
	titles TitleReader
}

// New builds the library service.
func New(repo Repository, titles TitleReader) *Service {
	return &Service{repo: repo, titles: titles}
}

// Watchlist returns saved titles, newest first.
func (s *Service) Watchlist(
	ctx context.Context,
	profileID string,
	kids bool,
) ([]contracts.TitleCard, error) {
	ids, err := s.repo.ListWatchlist(ctx, profileID)
	if err != nil {
		return nil, err
	}
	cards, err := s.titles.CardsByIDs(ctx, ids, kids)
	if err != nil {
		return nil, err
	}
	out := make([]contracts.TitleCard, 0, len(ids))
	for _, id := range ids {
		if card, ok := cards[id]; ok {
			out = append(out, card)
		}
	}
	return out, nil
}

// Add saves a title after verifying it exists and is allowed for the profile.
func (s *Service) Add(ctx context.Context, profileID, titleID string, kids bool) error {
	cards, err := s.titles.CardsByIDs(ctx, []string{titleID}, kids)
	if err != nil {
		return err
	}
	if _, ok := cards[titleID]; !ok {
		return apperr.New(apperr.KindNotFound, "title not found")
	}
	return s.repo.AddToWatchlist(ctx, profileID, titleID)
}

// Remove deletes a saved title.
func (s *Service) Remove(ctx context.Context, profileID, titleID string) error {
	return s.repo.RemoveFromWatchlist(ctx, profileID, titleID)
}

// IsInWatchlist reports whether a title is saved (catalog ViewerState port).
func (s *Service) IsInWatchlist(ctx context.Context, profileID, titleID string) (bool, error) {
	return s.repo.IsInWatchlist(ctx, profileID, titleID)
}

// ProgressFor returns resumable progress, or nil when there is none. It
// satisfies catalog's ViewerState port.
func (s *Service) ProgressFor(
	ctx context.Context,
	profileID, titleID string,
) (*contracts.Progress, error) {
	progress, err := s.repo.GetProgress(ctx, profileID, titleID)
	if err != nil {
		if apperr.IsKind(err, apperr.KindNotFound) {
			return nil, nil
		}
		return nil, err
	}
	value := contracts.NewProgress(
		deref(progress.EpisodeID),
		progress.PositionSeconds,
		progress.DurationSeconds,
		progress.Completed,
	)
	return value, nil
}

// SaveProgress validates and persists a playback heartbeat.
func (s *Service) SaveProgress(
	ctx context.Context,
	profileID, titleID, episodeID string,
	position, duration int,
) error {
	if position < 0 {
		return apperr.New(apperr.KindValidation, "position_seconds must not be negative")
	}
	if duration <= 0 {
		return apperr.New(apperr.KindValidation, "duration_seconds must be positive")
	}
	if position > duration+60 {
		return apperr.New(apperr.KindValidation, "position_seconds exceeds duration")
	}
	if position > duration {
		position = duration
	}
	completed := position*100/duration >= 95
	var episodeRef *string
	if episodeID != "" {
		episodeRef = &episodeID
	}
	progress := &domain.Progress{
		ProfileID:       profileID,
		TitleID:         titleID,
		EpisodeID:       episodeRef,
		PositionSeconds: position,
		DurationSeconds: duration,
		Completed:       completed,
	}
	if err := s.repo.UpsertProgress(ctx, progress); err != nil {
		return err
	}
	return nil
}

// ContinueWatching returns cards with embedded progress for the home feed.
func (s *Service) ContinueWatching(
	ctx context.Context,
	profileID string,
	kids bool,
	limit int,
) ([]contracts.TitleCard, error) {
	if limit < 1 || limit > 30 {
		limit = 12
	}
	rows, err := s.repo.ContinueWatching(ctx, profileID, limit)
	if err != nil {
		return nil, err
	}
	ids := make([]string, 0, len(rows))
	for _, row := range rows {
		ids = append(ids, row.TitleID)
	}
	cards, err := s.titles.CardsByIDs(ctx, ids, kids)
	if err != nil {
		return nil, err
	}
	out := make([]contracts.TitleCard, 0, len(rows))
	for _, row := range rows {
		card, ok := cards[row.TitleID]
		if !ok {
			continue
		}
		card.Progress = contracts.NewProgress(
			deref(row.EpisodeID),
			row.PositionSeconds,
			row.DurationSeconds,
			row.Completed,
		)
		out = append(out, card)
	}
	return out, nil
}

func deref(value *string) string {
	if value == nil {
		return ""
	}
	return *value
}

// DeleteProfileState is called when a profile is removed.
func (s *Service) DeleteProfileState(ctx context.Context, profileID string) error {
	return s.repo.DeleteProfileState(ctx, profileID)
}
