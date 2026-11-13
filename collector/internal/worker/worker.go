// Package worker leases queued collection jobs and executes them.
package worker

import (
	"context"
	"errors"
	"log/slog"
	"time"

	"github.com/pagefau1t/speedvideo/collector/internal/model"
	"github.com/pagefau1t/speedvideo/collector/internal/pipeline"
	"github.com/pagefau1t/speedvideo/collector/internal/store"
)

// Worker runs a fixed-size pool of collection loops.
type Worker struct {
	store       *store.Store
	pipeline    *pipeline.Pipeline
	log         *slog.Logger
	concurrency int
	poll        time.Duration
}

// New builds a worker pool.
func New(
	store *store.Store,
	pipe *pipeline.Pipeline,
	log *slog.Logger,
	concurrency int,
	poll time.Duration,
) *Worker {
	if concurrency < 1 {
		concurrency = 1
	}
	return &Worker{
		store:       store,
		pipeline:    pipe,
		log:         log,
		concurrency: concurrency,
		poll:        poll,
	}
}

// Run starts the pool and blocks until the context is cancelled.
func (w *Worker) Run(ctx context.Context) {
	for index := 0; index < w.concurrency; index++ {
		go w.loop(ctx, index)
	}
	<-ctx.Done()
}

func (w *Worker) loop(ctx context.Context, index int) {
	log := w.log.With(slog.Int("worker", index))
	for {
		select {
		case <-ctx.Done():
			return
		default:
		}

		job, err := w.store.Claim(ctx)
		if errors.Is(err, store.ErrNoJob) {
			if !sleep(ctx, w.poll) {
				return
			}
			continue
		}
		if err != nil {
			log.Error("claim job", slog.String("error", err.Error()))
			if !sleep(ctx, w.poll) {
				return
			}
			continue
		}
		w.execute(ctx, log, job)
	}
}

func (w *Worker) execute(ctx context.Context, log *slog.Logger, job *model.Job) {
	attributes := []any{
		slog.String("job_id", job.ID),
		slog.String("source_id", job.SourceID),
		slog.String("kind", job.Kind),
		slog.String("remote_id", job.RemoteID),
	}
	log.Info("collect job started", attributes...)

	run, err := w.store.StartRun(ctx, job)
	if err != nil {
		log.Error("start run", append(attributes, slog.String("error", err.Error()))...)
		_ = w.store.Finish(ctx, job, err)
		return
	}

	stats, runErr := w.pipeline.Run(ctx, job)
	run.Fetched = stats.Fetched
	run.Created = stats.Created
	run.Updated = stats.Updated
	run.Skipped = stats.Skipped
	run.Failed = stats.Failed
	if err := w.store.FinishRun(ctx, run, runErr); err != nil {
		log.Error("finish run", append(attributes, slog.String("error", err.Error()))...)
	}
	if err := w.store.Finish(ctx, job, runErr); err != nil {
		log.Error("finish job", append(attributes, slog.String("error", err.Error()))...)
	}

	if runErr != nil {
		log.Error("collect job failed",
			append(attributes, slog.String("error", runErr.Error()))...)
		return
	}
	log.Info("collect job finished", append(attributes,
		slog.Int("created", stats.Created),
		slog.Int("updated", stats.Updated),
		slog.Int("skipped", stats.Skipped),
		slog.Int("failed", stats.Failed),
	)...)
}

func sleep(ctx context.Context, duration time.Duration) bool {
	select {
	case <-ctx.Done():
		return false
	case <-time.After(duration):
		return true
	}
}
