// Package scheduler enqueues periodic incremental collection.
package scheduler

import (
	"context"
	"log/slog"
	"time"

	"github.com/pagefau1t/speedvideo/collector/internal/store"
)

// Scheduler periodically asks the store which providers are due.
type Scheduler struct {
	store    *store.Store
	log      *slog.Logger
	interval time.Duration
	tick     time.Duration
}

// New builds a scheduler. interval is how often each source is refreshed.
func New(store *store.Store, log *slog.Logger, interval, tick time.Duration) *Scheduler {
	if tick <= 0 {
		tick = time.Minute
	}
	return &Scheduler{store: store, log: log, interval: interval, tick: tick}
}

// Run blocks until the context is cancelled.
func (s *Scheduler) Run(ctx context.Context) {
	ticker := time.NewTicker(s.tick)
	defer ticker.Stop()
	s.enqueueDue(ctx)
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			s.enqueueDue(ctx)
		}
	}
}

func (s *Scheduler) enqueueDue(ctx context.Context) {
	sources, err := s.store.SourcesDue(ctx, s.interval)
	if err != nil {
		s.log.Error("list due sources", slog.String("error", err.Error()))
		return
	}
	for _, source := range sources {
		if _, err := s.store.Enqueue(ctx, source.ID, "incremental", ""); err != nil {
			s.log.Error("enqueue incremental",
				slog.String("source", source.Slug),
				slog.String("error", err.Error()))
			continue
		}
		s.log.Info("incremental collection queued", slog.String("source", source.Slug))
	}
}
