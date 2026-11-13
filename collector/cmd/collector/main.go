// Command collector is a standalone content ingestion worker.
//
// It has no HTTP server and exposes no API: the control plane lives in the API
// process, which owns the source registry and the job queue. The collector
// connects to the same PostgreSQL database, leases due jobs and writes the
// normalised catalogue, so a slow or failing provider can never affect viewer
// or operator traffic.
package main

import (
	"context"
	"database/sql"
	"log/slog"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	_ "github.com/lib/pq"

	"github.com/pagefau1t/speedvideo/collector/internal/adapter"
	"github.com/pagefau1t/speedvideo/collector/internal/config"
	"github.com/pagefau1t/speedvideo/collector/internal/pipeline"
	"github.com/pagefau1t/speedvideo/collector/internal/scheduler"
	"github.com/pagefau1t/speedvideo/collector/internal/store"
	"github.com/pagefau1t/speedvideo/collector/internal/worker"
)

func main() {
	if len(os.Args) > 1 && os.Args[1] == "healthcheck" {
		healthcheck()
		return
	}

	cfg, err := config.Load()
	if err != nil {
		slog.Error("invalid configuration", slog.String("error", err.Error()))
		os.Exit(1)
	}
	log := newLogger(cfg)
	slog.SetDefault(log)

	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	db, err := store.Open(ctx, cfg.DatabaseURL)
	if err != nil {
		log.Error("connect database", slog.String("error", err.Error()))
		os.Exit(1)
	}
	defer func() {
		if err := db.Close(); err != nil {
			log.Error("close database", slog.String("error", err.Error()))
		}
	}()

	if err := db.WaitForSchema(ctx, 90*time.Second); err != nil {
		log.Error("shared schema is not ready", slog.String("error", err.Error()))
		os.Exit(1)
	}

	adapters := adapter.NewRegistry(adapter.NewAppleCMS())
	pipe := pipeline.New(db, adapters, cfg.AllowInsecure, cfg.MaxPages,
		cfg.IncrementalPages, cfg.UnchangedWindow)

	if cfg.Once {
		runOnce(ctx, db, log, pipe)
		return
	}

	go worker.New(db, pipe, log, cfg.Concurrency, cfg.PollInterval).Run(ctx)
	go scheduler.New(db, log, cfg.SyncInterval, time.Minute).Run(ctx)

	log.Info("collector started",
		slog.Int("concurrency", cfg.Concurrency),
		slog.Duration("sync_interval", cfg.SyncInterval),
	)
	<-ctx.Done()
	log.Info("collector shutting down")
}

// runOnce performs a full scan of every enabled source, then returns. It is
// used by CI and by operators who prefer external scheduling.
func runOnce(ctx context.Context, db *store.Store, log *slog.Logger, pipe *pipeline.Pipeline) {
	sources, err := db.ListSources(ctx)
	if err != nil {
		log.Error("list sources", slog.String("error", err.Error()))
		os.Exit(1)
	}
	exitCode := 0
	for _, source := range sources {
		if !source.Enabled {
			continue
		}
		job, err := db.Enqueue(ctx, source.ID, "full", "")
		if err != nil {
			log.Error(
				"enqueue",
				slog.String("source", source.Slug),
				slog.String("error", err.Error()),
			)
			exitCode = 1
			continue
		}
		if _, err := pipe.Run(ctx, job); err != nil {
			log.Error(
				"collect",
				slog.String("source", source.Slug),
				slog.String("error", err.Error()),
			)
			exitCode = 1
		}
	}
	os.Exit(exitCode)
}

func newLogger(cfg *config.Config) *slog.Logger {
	level := slog.LevelInfo
	switch cfg.LogLevel {
	case "debug":
		level = slog.LevelDebug
	case "warn":
		level = slog.LevelWarn
	case "error":
		level = slog.LevelError
	}
	handler := slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: level})
	return slog.New(handler).With(
		slog.String("service", "speedvideo-collector"),
		slog.String("env", cfg.Environment),
	)
}

// healthcheck backs the container HEALTHCHECK. The collector serves no HTTP
// surface, so readiness is a database round trip on the shared schema.
func healthcheck() {
	dsn := strings.TrimSpace(os.Getenv("DATABASE_URL"))
	if dsn == "" {
		os.Exit(1)
	}
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		os.Exit(1)
	}
	defer func() { _ = db.Close() }()

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	if err := db.PingContext(ctx); err != nil {
		os.Exit(1)
	}
	os.Exit(0)
}
