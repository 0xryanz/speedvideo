// Package worker leases queued collection jobs and executes them.
package worker

import (
	"context"
	"errors"
	"log/slog"
	"os"
	"sync"
	"time"

	"github.com/google/uuid"

	"github.com/pagefau1t/speedvideo/collector/internal/model"
	"github.com/pagefau1t/speedvideo/collector/internal/pipeline"
	"github.com/pagefau1t/speedvideo/collector/internal/store"
)

// cleanupTimeout bounds the database work that must still happen after the
// process is asked to stop. It runs on a detached context so a cancelled
// shutdown signal cannot leave a job marked as running forever.
const cleanupTimeout = 15 * time.Second

// Worker runs a fixed-size pool of collection loops.
type Worker struct {
	store       *store.Store
	pipeline    *pipeline.Pipeline
	log         *slog.Logger
	concurrency int
	poll        time.Duration
	owner       string
	lease       time.Duration
}

// New builds a worker pool.
func New(
	store *store.Store,
	pipe *pipeline.Pipeline,
	log *slog.Logger,
	concurrency int,
	poll time.Duration,
	lease time.Duration,
) *Worker {
	if concurrency < 1 {
		concurrency = 1
	}
	if lease < time.Second {
		lease = time.Minute
	}
	host, err := os.Hostname()
	if err != nil || host == "" {
		host = "collector"
	}
	return &Worker{
		store:       store,
		pipeline:    pipe,
		log:         log,
		concurrency: concurrency,
		poll:        poll,
		owner:       host + "-" + uuid.NewString()[:8],
		lease:       lease,
	}
}

// Run starts the pool and blocks until every worker has stopped, including the
// job it was executing. Callers can therefore rely on the returned write
// having released or finished its lease before the process exits.
func (w *Worker) Run(ctx context.Context) {
	var wg sync.WaitGroup
	for index := 0; index < w.concurrency; index++ {
		wg.Add(1)
		go func(index int) {
			defer wg.Done()
			w.loop(ctx, index)
		}(index)
	}
	<-ctx.Done()
	wg.Wait()
}

func (w *Worker) loop(ctx context.Context, index int) {
	log := w.log.With(slog.Int("worker", index))
	for {
		select {
		case <-ctx.Done():
			return
		default:
		}

		job, err := w.store.Claim(ctx, w.owner, w.lease)
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
		slog.String("lease_owner", w.owner),
	}
	log.Info("collect job started", attributes...)
	started := time.Now()

	runCtx, cancelRun := context.WithCancel(ctx)
	defer cancelRun()
	leaseDone := make(chan struct{})
	go w.keepLease(runCtx, log, job, cancelRun, leaseDone)

	run, err := w.store.StartRun(runCtx, job)
	if err != nil {
		cancelRun()
		<-leaseDone
		log.Error("start run", append(attributes, slog.String("error", err.Error()))...)
		w.finish(log, attributes, job, ctx.Err() != nil, err)
		return
	}

	stats, runErr := w.pipeline.Run(runCtx, job)
	cancelRun()
	<-leaseDone

	run.Fetched = stats.Fetched
	run.Created = stats.Created
	run.Updated = stats.Updated
	run.Skipped = stats.Skipped
	run.Failed = stats.Failed

	// The signal that stopped this run also cancelled runCtx. Clean up on a
	// fresh context so the lease release reaches the database before exit.
	cleanupCtx, cancelCleanup := context.WithTimeout(context.Background(), cleanupTimeout)
	defer cancelCleanup()

	if err := w.store.FinishRun(cleanupCtx, run, runErr); err != nil {
		log.Error("finish run", append(attributes, slog.String("error", err.Error()))...)
	}

	interrupted := runErr != nil && ctx.Err() != nil
	finishErr := w.store.Finish(cleanupCtx, job, w.owner, interrupted, runErr)
	if errors.Is(finishErr, store.ErrLeaseLost) {
		log.Warn("collect job lease was taken over; leaving it to the new owner",
			attributes...)
		return
	}
	if finishErr != nil {
		log.Error("finish job", append(attributes, slog.String("error", finishErr.Error()))...)
	}

	if interrupted {
		log.Info("collect job interrupted; returned to the queue", attributes...)
		return
	}
	if runErr != nil {
		log.Error("collect job failed",
			append(attributes, slog.String("error", runErr.Error()))...)
		return
	}
	log.Info("collect job finished", append(attributes,
		slog.Int("fetched", stats.Fetched),
		slog.Int("created", stats.Created),
		slog.Int("updated", stats.Updated),
		slog.Int("skipped", stats.Skipped),
		slog.Int("failed", stats.Failed),
		slog.Duration("duration", time.Since(started)),
	)...)
}

// finish releases a job whose run could not even be recorded.
func (w *Worker) finish(
	log *slog.Logger,
	attributes []any,
	job *model.Job,
	interrupted bool,
	jobErr error,
) {
	cleanupCtx, cancel := context.WithTimeout(context.Background(), cleanupTimeout)
	defer cancel()
	if err := w.store.Finish(cleanupCtx, job, w.owner, interrupted, jobErr); err != nil {
		if errors.Is(err, store.ErrLeaseLost) {
			log.Warn("collect job lease was taken over", attributes...)
			return
		}
		log.Error("finish job", append(attributes, slog.String("error", err.Error()))...)
	}
}

// keepLease renews the job lease while the pipeline runs. If the renewal is
// rejected, another collector owns the job now; cancelling stops this worker
// from duplicating the work.
func (w *Worker) keepLease(
	ctx context.Context,
	log *slog.Logger,
	job *model.Job,
	cancel context.CancelFunc,
	done chan<- struct{},
) {
	defer close(done)
	interval := w.lease / 3
	if interval < time.Second {
		interval = time.Second
	}
	ticker := time.NewTicker(interval)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			held, err := w.store.RenewLease(ctx, job.ID, w.owner, w.lease)
			if err != nil {
				if ctx.Err() != nil {
					return
				}
				log.Warn("renew job lease",
					slog.String("job_id", job.ID),
					slog.String("error", err.Error()))
				continue
			}
			if !held {
				log.Error("job lease lost; stopping this run",
					slog.String("job_id", job.ID))
				cancel()
				return
			}
		}
	}
}

func sleep(ctx context.Context, duration time.Duration) bool {
	select {
	case <-ctx.Done():
		return false
	case <-time.After(duration):
		return true
	}
}
