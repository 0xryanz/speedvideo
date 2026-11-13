// Command migrate applies pending ORM migrations without starting the API or
// seeding starter content. Production deployments run this as a one-off job.
package main

import (
	"context"
	"log/slog"

	"github.com/pagefau1t/speedvideo/api/internal/migrations"
	"github.com/pagefau1t/speedvideo/api/internal/platform/config"
	"github.com/pagefau1t/speedvideo/api/internal/platform/database"
	"github.com/pagefau1t/speedvideo/api/internal/platform/logger"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		logger.Fatal(slog.Default(), "invalid configuration", err)
	}
	log := logger.New(cfg)
	slog.SetDefault(log)

	ctx := context.Background()
	db, err := database.Open(ctx, cfg, log)
	if err != nil {
		logger.Fatal(log, "connect database", err)
	}
	defer func() {
		if err := database.Close(db); err != nil {
			log.Error("close database", slog.String("error", err.Error()))
		}
	}()

	if err := migrations.Run(db, log); err != nil {
		logger.Fatal(log, "apply migrations", err)
	}
}
