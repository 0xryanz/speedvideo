// Package database owns the process' GORM connection lifecycle. Individual
// feature modules never construct database handles; they receive repositories
// wired by the application composition root.
package database

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	gormlogger "gorm.io/gorm/logger"

	"github.com/pagefau1t/speedvideo/api/internal/platform/config"
)

// Open connects to PostgreSQL, verifies connectivity and configures the
// connection pool. It never runs schema changes; migrations are explicit.
func Open(ctx context.Context, cfg *config.Config, log *slog.Logger) (*gorm.DB, error) {
	gormLog := gormlogger.New(
		&slogWriter{log: log.With(slog.String("component", "gorm"))},
		gormlogger.Config{
			SlowThreshold:             300 * time.Millisecond,
			LogLevel:                  gormlogger.Warn,
			IgnoreRecordNotFoundError: true,
			Colorful:                  false,
		},
	)

	db, err := gorm.Open(postgres.Open(cfg.DatabaseURL), &gorm.Config{
		Logger:                 gormLog,
		SkipDefaultTransaction: false,
		PrepareStmt:            true,
		NowFunc:                func() time.Time { return time.Now().UTC() },
		TranslateError:         true,
	})
	if err != nil {
		return nil, fmt.Errorf("open database: %w", err)
	}

	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("unwrap database pool: %w", err)
	}
	sqlDB.SetMaxOpenConns(cfg.DBMaxOpenConns)
	sqlDB.SetMaxIdleConns(cfg.DBMaxIdleConns)
	sqlDB.SetConnMaxLifetime(cfg.DBConnMaxLife)
	sqlDB.SetConnMaxIdleTime(5 * time.Minute)

	pingCtx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()
	if err := sqlDB.PingContext(pingCtx); err != nil {
		return nil, fmt.Errorf("ping database: %w", err)
	}
	return db, nil
}

// Close releases the underlying connection pool.
func Close(db *gorm.DB) error {
	if db == nil {
		return nil
	}
	sqlDB, err := db.DB()
	if err != nil {
		return err
	}
	return sqlDB.Close()
}

// Ping is used by the readiness probe.
func Ping(ctx context.Context, db *gorm.DB) error {
	if db == nil {
		return errors.New("database is not initialised")
	}
	sqlDB, err := db.DB()
	if err != nil {
		return err
	}
	return sqlDB.PingContext(ctx)
}

type slogWriter struct {
	log *slog.Logger
}

func (w *slogWriter) Printf(format string, args ...any) {
	w.log.Warn(fmt.Sprintf(format, args...))
}
