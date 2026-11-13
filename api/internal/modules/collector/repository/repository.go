// Package repository implements collection queue persistence with GORM. These
// tables are shared with the collector process: the API writes and reads them,
// the collector leases and executes jobs.
package repository

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"gorm.io/gorm"

	"github.com/pagefau1t/speedvideo/api/internal/modules/collector/domain"
	"github.com/pagefau1t/speedvideo/api/internal/platform/apperr"
)

// Filter narrows a job listing.
type Filter struct {
	SourceID string
	Status   string
	Kind     string
	Limit    int
	Offset   int
}

// RunFilter narrows an execution listing.
type RunFilter struct {
	SourceID string
	Kind     string
	Limit    int
	Offset   int
}

// ItemFilter narrows collected provider entries.
type ItemFilter struct {
	SourceID string
	Query    string
	Removed  *bool
	Limit    int
	Offset   int
}

// ItemRow is one collected provider entry with display labels.
type ItemRow struct {
	ID          string     `json:"id"`
	SourceID    string     `json:"source_id"`
	SourceName  string     `json:"source_name"`
	RemoteID    string     `json:"remote_id"`
	TitleID     string     `json:"title_id"`
	TitleName   string     `json:"title_name"`
	TitleSlug   string     `json:"title_slug"`
	ContentHash string     `json:"content_hash"`
	LastSeenAt  time.Time  `json:"last_seen_at"`
	RemovedAt   *time.Time `json:"removed_at,omitempty"`
}

// Stats is the operations console overview.
type Stats struct {
	Sources        int64      `json:"sources"`
	EnabledSources int64      `json:"enabled_sources"`
	JobsPending    int64      `json:"jobs_pending"`
	JobsRunning    int64      `json:"jobs_running"`
	JobsFailed     int64      `json:"jobs_failed"`
	Titles         int64      `json:"titles"`
	Items          int64      `json:"items"`
	ItemsRemoved   int64      `json:"items_removed"`
	Runs           int64      `json:"runs"`
	LastRunAt      *time.Time `json:"last_run_at,omitempty"`
}

// Repository is the collection queue gateway.
type Repository struct {
	db *gorm.DB
}

// New builds the repository.
func New(db *gorm.DB) *Repository {
	return &Repository{db: db}
}

// Enqueue adds a job unless an equivalent one is already queued or running.
// Preview jobs are never deduplicated: two previews can target different
// queries.
func (r *Repository) Enqueue(
	ctx context.Context,
	sourceID, kind, remoteID, payload string,
) (*domain.Job, error) {
	if kind != domain.JobPreview {
		var existing domain.Job
		err := r.db.WithContext(ctx).
			Where("source_id = ? AND kind = ? AND remote_id = ? AND status IN ?",
				sourceID, kind, remoteID, []string{domain.JobPending, domain.JobRunning}).
			First(&existing).Error
		if err == nil {
			return &existing, nil
		}
		if !errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, fmt.Errorf("look up pending job: %w", err)
		}
	}
	job := &domain.Job{
		SourceID:    sourceID,
		Kind:        kind,
		RemoteID:    remoteID,
		Payload:     payload,
		Status:      domain.JobPending,
		MaxAttempts: 3,
		RunAfter:    time.Now().UTC(),
	}
	if err := r.db.WithContext(ctx).Create(job).Error; err != nil {
		return nil, fmt.Errorf("enqueue job: %w", err)
	}
	return job, nil
}

// ItemByTitleID resolves the provider row behind a catalogue title.
func (r *Repository) ItemByTitleID(ctx context.Context, titleID string) (*domain.Item, error) {
	var item domain.Item
	if err := r.db.WithContext(ctx).Where("title_id = ?", titleID).First(&item).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, apperr.New(apperr.KindNotFound, "title was not collected from a source")
		}
		return nil, fmt.Errorf("load collect item: %w", err)
	}
	return &item, nil
}

// GetJob loads one job including its payload and last result.
func (r *Repository) GetJob(ctx context.Context, id string) (*domain.Job, error) {
	var job domain.Job
	if err := r.db.WithContext(ctx).Where("id = ?", id).First(&job).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, apperr.New(apperr.KindNotFound, "job not found")
		}
		return nil, fmt.Errorf("load job: %w", err)
	}
	return &job, nil
}

// RetryJob re-queues a finished job from scratch.
func (r *Repository) RetryJob(ctx context.Context, id string) (*domain.Job, error) {
	result := r.db.WithContext(ctx).Model(&domain.Job{}).
		Where("id = ? AND status IN ?", id, []string{domain.JobFailed, domain.JobDone}).
		Updates(map[string]any{
			"status":     domain.JobPending,
			"attempts":   0,
			"run_after":  time.Now().UTC(),
			"last_error": "",
		})
	if result.Error != nil {
		return nil, fmt.Errorf("retry job: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return nil, apperr.New(apperr.KindConflict, "job is missing or still in flight")
	}
	return r.GetJob(ctx, id)
}

// ListJobs pages jobs newest first.
func (r *Repository) ListJobs(ctx context.Context, filter Filter) ([]domain.Job, int64, error) {
	query := r.db.WithContext(ctx).Model(&domain.Job{})
	if filter.SourceID != "" {
		query = query.Where("source_id = ?", filter.SourceID)
	}
	if filter.Status != "" {
		query = query.Where("status = ?", filter.Status)
	}
	if filter.Kind != "" {
		query = query.Where("kind = ?", filter.Kind)
	}
	var total int64
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, fmt.Errorf("count jobs: %w", err)
	}
	var jobs []domain.Job
	err := query.Order("created_at DESC").
		Limit(clampLimit(filter.Limit)).
		Offset(clampOffset(filter.Offset)).
		Find(&jobs).Error
	if err != nil {
		return nil, 0, fmt.Errorf("list jobs: %w", err)
	}
	return jobs, total, nil
}

// ListRuns pages executions newest first.
func (r *Repository) ListRuns(ctx context.Context, filter RunFilter) ([]domain.Run, int64, error) {
	query := r.db.WithContext(ctx).Model(&domain.Run{})
	if filter.SourceID != "" {
		query = query.Where("source_id = ?", filter.SourceID)
	}
	if filter.Kind != "" {
		query = query.Where("kind = ?", filter.Kind)
	}
	var total int64
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, fmt.Errorf("count runs: %w", err)
	}
	var runs []domain.Run
	err := query.Order("started_at DESC").
		Limit(clampLimit(filter.Limit)).
		Offset(clampOffset(filter.Offset)).
		Find(&runs).Error
	if err != nil {
		return nil, 0, fmt.Errorf("list runs: %w", err)
	}
	return runs, total, nil
}

// ListItems pages collected provider entries.
func (r *Repository) ListItems(ctx context.Context, filter ItemFilter) ([]ItemRow, int64, error) {
	base := func() *gorm.DB {
		query := r.db.WithContext(ctx).Table("collect_items ci").
			Joins("LEFT JOIN content_sources cs ON cs.id = ci.source_id").
			Joins("LEFT JOIN titles t ON t.id = ci.title_id")
		if filter.SourceID != "" {
			query = query.Where("ci.source_id = ?", filter.SourceID)
		}
		if term := strings.TrimSpace(filter.Query); term != "" {
			pattern := "%" + term + "%"
			query = query.Where("t.name ILIKE ? OR ci.remote_id ILIKE ?", pattern, pattern)
		}
		if filter.Removed != nil {
			if *filter.Removed {
				query = query.Where("ci.removed_at IS NOT NULL")
			} else {
				query = query.Where("ci.removed_at IS NULL")
			}
		}
		return query
	}

	var total int64
	if err := base().Count(&total).Error; err != nil {
		return nil, 0, fmt.Errorf("count items: %w", err)
	}
	var rows []ItemRow
	err := base().
		Select(`ci.id, ci.source_id, COALESCE(cs.name, '') AS source_name,
			ci.remote_id, ci.title_id, COALESCE(t.name, '') AS title_name,
			COALESCE(t.slug, '') AS title_slug,
			ci.content_hash, ci.last_seen_at, ci.removed_at`).
		Order("ci.last_seen_at DESC").
		Limit(clampLimit(filter.Limit)).
		Offset(clampOffset(filter.Offset)).
		Scan(&rows).Error
	if err != nil {
		return nil, 0, fmt.Errorf("list items: %w", err)
	}
	return rows, total, nil
}

// Stats aggregates the collection tables for the dashboard.
func (r *Repository) Stats(ctx context.Context) (Stats, error) {
	var stats Stats
	db := r.db.WithContext(ctx)
	counts := []struct {
		target *int64
		query  func() *gorm.DB
	}{
		{&stats.Sources, func() *gorm.DB { return db.Table("content_sources") }},
		{
			&stats.EnabledSources,
			func() *gorm.DB { return db.Table("content_sources").Where("enabled = ?", true) },
		},
		{
			&stats.JobsPending,
			func() *gorm.DB { return db.Model(&domain.Job{}).Where("status = ?", domain.JobPending) },
		},
		{
			&stats.JobsRunning,
			func() *gorm.DB { return db.Model(&domain.Job{}).Where("status = ?", domain.JobRunning) },
		},
		{
			&stats.JobsFailed,
			func() *gorm.DB { return db.Model(&domain.Job{}).Where("status = ?", domain.JobFailed) },
		},
		{
			&stats.Titles,
			func() *gorm.DB { return db.Table("titles").Where("source_id IS NOT NULL") },
		},
		{&stats.Items, func() *gorm.DB { return db.Model(&domain.Item{}) }},
		{
			&stats.ItemsRemoved,
			func() *gorm.DB { return db.Model(&domain.Item{}).Where("removed_at IS NOT NULL") },
		},
		{&stats.Runs, func() *gorm.DB { return db.Model(&domain.Run{}) }},
	}
	for _, count := range counts {
		if err := count.query().Count(count.target).Error; err != nil {
			return Stats{}, fmt.Errorf("count collection tables: %w", err)
		}
	}
	var last domain.Run
	if err := db.Order("started_at DESC").First(&last).Error; err == nil {
		stats.LastRunAt = &last.StartedAt
	} else if !errors.Is(err, gorm.ErrRecordNotFound) {
		return Stats{}, fmt.Errorf("load last run: %w", err)
	}
	return stats, nil
}

func clampLimit(limit int) int {
	if limit < 1 {
		return 50
	}
	if limit > 200 {
		return 200
	}
	return limit
}

func clampOffset(offset int) int {
	if offset < 0 {
		return 0
	}
	return offset
}
