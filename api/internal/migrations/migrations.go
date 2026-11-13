// Package migrations applies versioned, ORM-driven schema changes. There is no
// hand-written SQL anywhere in the service: GORM's migrator is the single
// source of schema truth. Future releases append migrations instead of
// mutating earlier ones.
package migrations

import (
	"fmt"
	"log/slog"
	"time"

	"github.com/go-gormigrate/gormigrate/v2"
	"gorm.io/gorm"

	catalogdomain "github.com/pagefau1t/speedvideo/api/internal/modules/catalog/domain"
	collectordomain "github.com/pagefau1t/speedvideo/api/internal/modules/collector/domain"
	identitydomain "github.com/pagefau1t/speedvideo/api/internal/modules/identity/domain"
	librarydomain "github.com/pagefau1t/speedvideo/api/internal/modules/library/domain"
	sourcedomain "github.com/pagefau1t/speedvideo/api/internal/modules/source/domain"
)

// Run applies all outstanding migrations.
func Run(db *gorm.DB, log *slog.Logger) error {
	migrator := gormigrate.New(db, &gormigrate.Options{
		TableName:                 "schema_migrations",
		IDColumnName:              "id",
		IDColumnSize:              255,
		UseTransaction:            true,
		ValidateUnknownMigrations: true,
	}, []*gormigrate.Migration{
		{
			ID: "202601010001_initial_schema",
			Migrate: func(tx *gorm.DB) error {
				return tx.AutoMigrate(
					&identitydomain.User{},
					&identitydomain.Profile{},
					&identitydomain.RefreshToken{},
					&catalogdomain.Genre{},
					&catalogdomain.Title{},
					&catalogdomain.Season{},
					&catalogdomain.Episode{},
					&librarydomain.WatchlistEntry{},
					&librarydomain.Progress{},
				)
			},
		},
		{
			ID: "202602010001_offline_downloads",
			Migrate: func(tx *gorm.DB) error {
				// AutoMigrate adds the download rendition columns; the starter seed
				// backfills renditions for existing rows.
				return tx.AutoMigrate(&catalogdomain.Title{}, &catalogdomain.Episode{})
			},
		},
		{
			ID: "202604010002_title_tombstones",
			Migrate: func(tx *gorm.DB) error {
				return tx.AutoMigrate(&catalogdomain.Title{})
			},
		},
		{
			ID: "202604010004_collect_queue",
			Migrate: func(tx *gorm.DB) error {
				// The API owns every table, including the queue consumed by the
				// separate collector process. Idempotent so deployments that
				// already had the collector create these tables keep working.
				return tx.AutoMigrate(
					&collectordomain.Job{},
					&collectordomain.Run{},
					&collectordomain.Item{},
				)
			},
		},
		{
			ID: "202604010003_title_work_keys",
			Migrate: func(tx *gorm.DB) error {
				// work_key is written by the collector when it detects the same
				// work in several sources. Rows that predate this migration are
				// ungrouped; keep them visible as their own canonical entries.
				if err := tx.AutoMigrate(&catalogdomain.Title{}); err != nil {
					return err
				}
				return tx.Model(&catalogdomain.Title{}).
					Where("work_key = ?", "").
					Update("canonical", true).Error
			},
		},
		{
			ID: "202604010001_purge_starter_catalogue",
			Migrate: func(tx *gorm.DB) error {
				// Earlier releases installed a demo catalogue on boot. Remove it
				// so installations start empty and only show content written by
				// the collector. Scoped to rows never linked to a content source
				// so operator-curated and collected titles are untouched.
				var ids []string
				if err := tx.Model(&catalogdomain.Title{}).
					Where("source_id IS NULL AND slug IN ?", starterCatalogueSlugs).
					Pluck("id", &ids).Error; err != nil {
					return err
				}
				if len(ids) == 0 {
					return nil
				}
				// The many-to-many join table has no cascade; clear it first.
				if err := tx.Where("title_id IN ?", ids).Delete(&titleGenre{}).Error; err != nil {
					return err
				}
				return tx.Where("id IN ?", ids).Delete(&catalogdomain.Title{}).Error
			},
		},
		{
			ID: "202603010001_content_sources",
			Migrate: func(tx *gorm.DB) error {
				// Adds the operator-managed provider registry plus the
				// provenance columns that let playback re-check a title's
				// provider on every grant redemption.
				return tx.AutoMigrate(
					&sourcedomain.Source{},
					&catalogdomain.Title{},
					&catalogdomain.Episode{},
				)
			},
		},
		{
			ID: "202605010001_source_type_filters",
			Migrate: func(tx *gorm.DB) error {
				// Category selection and a per-source page cap let operators
				// collect only the content types they want, and walk deeper
				// than the global page limit when they do.
				return tx.AutoMigrate(&sourcedomain.Source{})
			},
		},
		{
			ID: "202611130001_job_leases",
			Migrate: func(tx *gorm.DB) error {
				// Jobs claimed by a collector now carry a lease. Rows left
				// "running" before this migration cannot still be executing,
				// so return them to the queue instead of stranding them.
				if err := tx.AutoMigrate(&collectordomain.Job{}); err != nil {
					return err
				}
				return tx.Model(&collectordomain.Job{}).
					Where("status = ?", collectordomain.JobRunning).
					Updates(map[string]any{
						"status":           collectordomain.JobPending,
						"lease_owner":      "",
						"lease_expires_at": nil,
						"run_after":        time.Now().UTC(),
					}).Error
			},
		},
	})

	log.Info("running database migrations")
	if err := migrator.Migrate(); err != nil {
		return fmt.Errorf("apply migrations: %w", err)
	}
	log.Info("database migrations are up to date")
	return nil
}

// starterCatalogueSlugs is the exact set of titles shipped by the retired demo
// seed. It is frozen here so the cleanup stays reproducible after the seed
// package is deleted.
var starterCatalogueSlugs = []string{
	"inception", "interstellar", "the-dark-knight", "the-matrix", "dune",
	"oppenheimer", "shawshank-redemption", "parasite", "mad-max-fury-road",
	"spider-verse", "joker", "grand-budapest-hotel", "blade-runner-2049",
	"everything-everywhere", "whiplash", "stranger-things", "wednesday",
	"breaking-bad", "squid-game", "the-witcher", "arcane", "the-last-of-us",
	"money-heist", "dark", "queens-gambit", "peaky-blinders", "paddington-2",
	"mario-movie", "klaus", "bluey",
}

// titleGenre is the GORM-managed join table for title↔genre.
type titleGenre struct {
	TitleID string `gorm:"column:title_id"`
	GenreID string `gorm:"column:genre_id"`
}

func (titleGenre) TableName() string { return "title_genres" }
