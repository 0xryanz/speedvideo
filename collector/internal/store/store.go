// Package store is the collector's persistence layer. It owns collect_jobs,
// collect_runs and collect_items, and writes content_sources plus the catalogue
// tables that the API serves.
package store

import (
	"context"
	"errors"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/google/uuid"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
	"gorm.io/gorm/logger"

	"github.com/pagefau1t/speedvideo/collector/internal/model"
)

// ErrNoJob is returned by Claim when the queue is empty.
var ErrNoJob = errors.New("no pending collection job")

// ErrLeaseLost is returned by Finish when another collector now owns the job.
// The caller must leave it alone: the new lease holder will complete it.
var ErrLeaseLost = errors.New("collection job lease is no longer held")

// Store wraps the database handle.
type Store struct {
	db *gorm.DB
}

// Open connects to PostgreSQL.
func Open(ctx context.Context, dsn string) (*Store, error) {
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.New(
			log.New(os.Stderr, "", log.LstdFlags),
			logger.Config{
				SlowThreshold:             time.Second,
				LogLevel:                  logger.Warn,
				IgnoreRecordNotFoundError: true,
			},
		),
	})
	if err != nil {
		return nil, fmt.Errorf("connect database: %w", err)
	}
	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("acquire sql handle: %w", err)
	}
	sqlDB.SetMaxOpenConns(20)
	sqlDB.SetMaxIdleConns(10)
	sqlDB.SetConnMaxLifetime(30 * time.Minute)
	if err := sqlDB.PingContext(ctx); err != nil {
		return nil, fmt.Errorf("ping database: %w", err)
	}
	return &Store{db: db}, nil
}

// Close releases the pool.
func (s *Store) Close() error {
	sqlDB, err := s.db.DB()
	if err != nil {
		return err
	}
	return sqlDB.Close()
}

// DB exposes the handle for health checks.
func (s *Store) DB() *gorm.DB { return s.db }

// WaitForSchema blocks until the API has created every shared table. The API
// owns the canonical schema; the collector only reads and writes data.
func (s *Store) WaitForSchema(ctx context.Context, timeout time.Duration) error {
	deadline := time.Now().Add(timeout)
	for {
		if s.db.Migrator().HasTable(&model.Source{}) &&
			s.db.Migrator().HasTable(&model.Title{}) &&
			s.db.Migrator().HasTable(&model.Job{}) &&
			s.db.Migrator().HasTable(&model.Run{}) &&
			s.db.Migrator().HasTable(&model.Item{}) {
			return nil
		}
		if time.Now().After(deadline) {
			return fmt.Errorf("catalogue schema is not ready: run the API migrations first")
		}
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-time.After(2 * time.Second):
		}
	}
}

// ListSources returns every configured provider.
func (s *Store) ListSources(ctx context.Context) ([]model.Source, error) {
	var sources []model.Source
	if err := s.db.WithContext(ctx).Order("name ASC").Find(&sources).Error; err != nil {
		return nil, fmt.Errorf("list sources: %w", err)
	}
	return sources, nil
}

// GetSource loads one provider by id.
func (s *Store) GetSource(ctx context.Context, id string) (*model.Source, error) {
	var source model.Source
	if err := s.db.WithContext(ctx).Where("id = ?", id).First(&source).Error; err != nil {
		return nil, fmt.Errorf("load source: %w", err)
	}
	return &source, nil
}

// Enqueue adds a job unless an equivalent one is already pending or running.
func (s *Store) Enqueue(ctx context.Context, sourceID, kind, remoteID string) (*model.Job, error) {
	var existing model.Job
	err := s.db.WithContext(ctx).
		Where("source_id = ? AND kind = ? AND remote_id = ? AND status IN ?",
			sourceID, kind, remoteID, []string{"pending", "running"}).
		First(&existing).Error
	if err == nil {
		return &existing, nil
	}
	if !errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, fmt.Errorf("look up pending job: %w", err)
	}
	job := &model.Job{
		ID:          uuid.NewString(),
		SourceID:    sourceID,
		Kind:        kind,
		RemoteID:    remoteID,
		Status:      "pending",
		MaxAttempts: 3,
		RunAfter:    time.Now().UTC(),
	}
	if err := s.db.WithContext(ctx).Create(job).Error; err != nil {
		return nil, fmt.Errorf("enqueue job: %w", err)
	}
	return job, nil
}

// Claim atomically leases the next runnable job.
//
// A pending job is runnable when its run_after has passed. A running job is
// runnable again when its lease expired: that means the collector executing it
// crashed or was restarted, and the work must not be lost. Live jobs are left
// alone, so several collectors can share the queue safely.
func (s *Store) Claim(
	ctx context.Context,
	owner string,
	lease time.Duration,
) (*model.Job, error) {
	now := time.Now().UTC()
	var job model.Job
	err := s.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		err := tx.Clauses(clause.Locking{Strength: "UPDATE", Options: "SKIP LOCKED"}).
			Where(
				"(status = ? AND run_after <= ?) OR (status = ? AND (lease_expires_at IS NULL OR lease_expires_at < ?))",
				"pending", now, "running", now,
			).
			Order("run_after ASC").
			First(&job).Error
		if err != nil {
			return err
		}
		expires := now.Add(lease)
		return tx.Model(&job).Updates(map[string]any{
			"status":           "running",
			"attempts":         job.Attempts + 1,
			"lease_owner":      owner,
			"lease_expires_at": expires,
			"last_error":       "",
		}).Error
	})
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, ErrNoJob
	}
	if err != nil {
		return nil, fmt.Errorf("claim job: %w", err)
	}
	job.Attempts++
	job.Status = "running"
	job.LeaseOwner = owner
	expires := now.Add(lease)
	job.LeaseExpiresAt = &expires
	return &job, nil
}

// RenewLease extends a running job's lease. It reports false when the job is no
// longer held by this collector, which means another worker took it over.
func (s *Store) RenewLease(
	ctx context.Context,
	jobID, owner string,
	lease time.Duration,
) (bool, error) {
	result := s.db.WithContext(ctx).Model(&model.Job{}).
		Where("id = ? AND status = ? AND lease_owner = ?", jobID, "running", owner).
		Update("lease_expires_at", time.Now().UTC().Add(lease))
	if result.Error != nil {
		return false, fmt.Errorf("renew job lease: %w", result.Error)
	}
	return result.RowsAffected > 0, nil
}

// Finish completes a job, retrying with backoff until it runs out of attempts.
//
// interrupted marks a graceful shutdown: the work goes straight back to the
// queue instead of being treated as a provider failure. Updates are scoped to
// the lease owner so a worker that lost its lease cannot overwrite the new
// owner's result.
func (s *Store) Finish(
	ctx context.Context,
	job *model.Job,
	owner string,
	interrupted bool,
	jobErr error,
) error {
	updates := map[string]any{
		"last_error":       "",
		"lease_owner":      "",
		"lease_expires_at": nil,
	}
	switch {
	case jobErr == nil:
		updates["status"] = "done"
	case interrupted:
		updates["status"] = "pending"
		updates["run_after"] = time.Now().UTC()
		updates["last_error"] = "interrupted by collector shutdown"
		// The claim counted this attempt; a graceful stop is not a failure, so
		// hand the attempt back rather than exhausting the retry budget after a
		// few deployments.
		attempts := job.Attempts - 1
		if attempts < 0 {
			attempts = 0
		}
		updates["attempts"] = attempts
	default:
		updates["last_error"] = truncate(jobErr.Error(), 600)
		if job.Attempts >= job.MaxAttempts {
			updates["status"] = "failed"
		} else {
			updates["status"] = "pending"
			updates["run_after"] = time.Now().UTC().Add(time.Duration(job.Attempts) * time.Minute)
		}
	}
	result := s.db.WithContext(ctx).Model(&model.Job{}).
		Where("id = ? AND status = ? AND lease_owner = ?", job.ID, "running", owner).
		Updates(updates)
	if result.Error != nil {
		return fmt.Errorf("finish job: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return ErrLeaseLost
	}
	return nil
}

// StartRun records the beginning of an execution.
func (s *Store) StartRun(ctx context.Context, job *model.Job) (*model.Run, error) {
	run := &model.Run{
		ID:        uuid.NewString(),
		JobID:     job.ID,
		SourceID:  job.SourceID,
		Kind:      job.Kind,
		StartedAt: time.Now().UTC(),
	}
	if err := s.db.WithContext(ctx).Create(run).Error; err != nil {
		return nil, fmt.Errorf("start run: %w", err)
	}
	return run, nil
}

// FinishRun stores execution statistics.
func (s *Store) FinishRun(ctx context.Context, run *model.Run, runErr error) error {
	now := time.Now().UTC()
	run.FinishedAt = &now
	if runErr != nil {
		run.Error = truncate(runErr.Error(), 1000)
	}
	if err := s.db.WithContext(ctx).Save(run).Error; err != nil {
		return fmt.Errorf("finish run: %w", err)
	}
	return nil
}

// SetJobResult stores the snapshot produced by a preview job. The API serves it
// to the console; the collector never interprets its contents.
func (s *Store) SetJobResult(ctx context.Context, jobID, result string) error {
	if err := s.db.WithContext(ctx).Model(&model.Job{}).
		Where("id = ?", jobID).
		Update("result", result).Error; err != nil {
		return fmt.Errorf("store job result: %w", err)
	}
	return nil
}

// SourcesDue returns enabled providers whose last successful sync is older than
// the interval and that have no queued work.
func (s *Store) SourcesDue(ctx context.Context, interval time.Duration) ([]model.Source, error) {
	cutoff := time.Now().UTC().Add(-interval)
	var sources []model.Source
	err := s.db.WithContext(ctx).
		Where("enabled = ?", true).
		Where("last_synced_at IS NULL OR last_synced_at < ?", cutoff).
		Where(`NOT EXISTS (
			SELECT 1 FROM collect_jobs j
			WHERE j.source_id = content_sources.id AND j.status IN ('pending','running')
		)`).
		Find(&sources).Error
	if err != nil {
		return nil, fmt.Errorf("load due sources: %w", err)
	}
	return sources, nil
}

func truncate(value string, limit int) string {
	if len(value) <= limit {
		return value
	}
	return value[:limit]
}
