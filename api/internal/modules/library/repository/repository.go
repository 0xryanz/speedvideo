// Package repository implements library persistence with GORM.
package repository

import (
	"context"
	"errors"
	"fmt"
	"time"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"

	"github.com/pagefau1t/speedvideo/api/internal/modules/library/domain"
	"github.com/pagefau1t/speedvideo/api/internal/platform/apperr"
)

// Repository is the library persistence gateway.
type Repository struct {
	db *gorm.DB
}

// New builds a library repository.
func New(db *gorm.DB) *Repository {
	return &Repository{db: db}
}

// ListWatchlist returns title ids for a profile, newest first.
func (r *Repository) ListWatchlist(ctx context.Context, profileID string) ([]string, error) {
	var entries []domain.WatchlistEntry
	if err := r.db.WithContext(ctx).Where("profile_id = ?", profileID).
		Order("created_at DESC").Find(&entries).Error; err != nil {
		return nil, fmt.Errorf("list watchlist: %w", err)
	}
	ids := make([]string, 0, len(entries))
	for _, entry := range entries {
		ids = append(ids, entry.TitleID)
	}
	return ids, nil
}

// AddToWatchlist is idempotent.
func (r *Repository) AddToWatchlist(ctx context.Context, profileID, titleID string) error {
	entry := domain.WatchlistEntry{
		ProfileID: profileID,
		TitleID:   titleID,
		CreatedAt: time.Now().UTC(),
	}
	if err := r.db.WithContext(ctx).
		Clauses(clause.OnConflict{DoNothing: true}).
		Create(&entry).Error; err != nil {
		return fmt.Errorf("add to watchlist: %w", err)
	}
	return nil
}

// RemoveFromWatchlist is idempotent.
func (r *Repository) RemoveFromWatchlist(ctx context.Context, profileID, titleID string) error {
	if err := r.db.WithContext(ctx).
		Where("profile_id = ? AND title_id = ?", profileID, titleID).
		Delete(&domain.WatchlistEntry{}).Error; err != nil {
		return fmt.Errorf("remove from watchlist: %w", err)
	}
	return nil
}

// IsInWatchlist reports whether a title is saved.
func (r *Repository) IsInWatchlist(ctx context.Context, profileID, titleID string) (bool, error) {
	var count int64
	if err := r.db.WithContext(ctx).Model(&domain.WatchlistEntry{}).
		Where("profile_id = ? AND title_id = ?", profileID, titleID).
		Count(&count).Error; err != nil {
		return false, fmt.Errorf("check watchlist: %w", err)
	}
	return count > 0, nil
}

// GetProgress loads resumable progress for a profile and title.
func (r *Repository) GetProgress(
	ctx context.Context,
	profileID, titleID string,
) (*domain.Progress, error) {
	var progress domain.Progress
	if err := r.db.WithContext(ctx).
		Where("profile_id = ? AND title_id = ?", profileID, titleID).
		First(&progress).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, apperr.New(apperr.KindNotFound, "progress not found")
		}
		return nil, fmt.Errorf("load progress: %w", err)
	}
	return &progress, nil
}

// UpsertProgress atomically stores the latest playback position.
func (r *Repository) UpsertProgress(ctx context.Context, progress *domain.Progress) error {
	progress.UpdatedAt = time.Now().UTC()
	if err := r.db.WithContext(ctx).Clauses(clause.OnConflict{
		Columns: []clause.Column{{Name: "profile_id"}, {Name: "title_id"}},
		DoUpdates: clause.Assignments(map[string]any{
			"episode_id":       progress.EpisodeID,
			"position_seconds": progress.PositionSeconds,
			"duration_seconds": progress.DurationSeconds,
			"completed":        progress.Completed,
			"updated_at":       progress.UpdatedAt,
		}),
	}).Create(progress).Error; err != nil {
		return fmt.Errorf("upsert progress: %w", err)
	}
	return nil
}

// ContinueWatching returns in-progress rows, most recent first.
func (r *Repository) ContinueWatching(
	ctx context.Context,
	profileID string,
	limit int,
) ([]domain.Progress, error) {
	var rows []domain.Progress
	if err := r.db.WithContext(ctx).
		Where("profile_id = ? AND completed = ? AND position_seconds > ?", profileID, false, 20).
		Order("updated_at DESC").Limit(limit).Find(&rows).Error; err != nil {
		return nil, fmt.Errorf("list continue watching: %w", err)
	}
	return rows, nil
}

// DeleteProfileState removes watchlist and progress rows for a deleted profile.
func (r *Repository) DeleteProfileState(ctx context.Context, profileID string) error {
	err := r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		if err := tx.Where("profile_id = ?", profileID).Delete(&domain.WatchlistEntry{}).Error; err != nil {
			return err
		}
		return tx.Where("profile_id = ?", profileID).Delete(&domain.Progress{}).Error
	})
	if err != nil {
		return fmt.Errorf("delete profile library state: %w", err)
	}
	return nil
}
