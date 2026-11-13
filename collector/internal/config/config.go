// Package config is the collector's environment-driven configuration.
package config

import (
	"fmt"
	"strings"
	"time"

	"github.com/caarlos0/env/v11"
)

// Config describes one collector process.
type Config struct {
	Environment  string        `env:"APP_ENV"                     envDefault:"development"`
	DatabaseURL  string        `env:"DATABASE_URL"`
	LogLevel     string        `env:"LOG_LEVEL"                   envDefault:"info"`
	Concurrency  int           `env:"COLLECTOR_CONCURRENCY"       envDefault:"2"`
	PollInterval time.Duration `env:"COLLECTOR_POLL_INTERVAL"     envDefault:"10s"`
	// SyncInterval is how often each enabled source is refreshed automatically.
	SyncInterval time.Duration `env:"COLLECTOR_SYNC_INTERVAL"     envDefault:"6h"`
	// MaxPages caps a full scan; 0 means unbounded.
	MaxPages int `env:"COLLECTOR_MAX_PAGES"         envDefault:"50"`
	// FetchConcurrency is the number of provider detail requests in flight.
	FetchConcurrency int `env:"COLLECTOR_FETCH_CONCURRENCY" envDefault:"8"`
	// ListConcurrency is the number of list pages fetched in parallel.
	ListConcurrency int `env:"COLLECTOR_LIST_CONCURRENCY"  envDefault:"4"`
	// IncrementalPages caps how many newest pages an incremental run walks.
	IncrementalPages int `env:"COLLECTOR_INCREMENTAL_PAGES" envDefault:"3"`
	// UnchangedWindow skips detail fetches for rows seen within this window.
	UnchangedWindow time.Duration `env:"COLLECTOR_UNCHANGED_WINDOW"  envDefault:"12h"`
	// JobLease is how long a claimed job stays reserved. It is renewed while
	// the job runs; after a crash the job becomes claimable again when the
	// lease expires, so unfinished work is never stranded.
	JobLease time.Duration `env:"COLLECTOR_JOB_LEASE"       envDefault:"60s"`
	// AllowInsecure permits plain-http provider endpoints and renditions. It is
	// rejected outside development.
	AllowInsecure bool `env:"COLLECTOR_ALLOW_INSECURE"    envDefault:"false"`
	// Once runs a single full scan for every enabled source and exits.
	Once bool `env:"COLLECTOR_ONCE"              envDefault:"false"`
}

// Load parses and validates the environment.
func Load() (*Config, error) {
	cfg := &Config{}
	if err := env.Parse(cfg); err != nil {
		return nil, fmt.Errorf("parse environment: %w", err)
	}
	cfg.Environment = strings.ToLower(strings.TrimSpace(cfg.Environment))
	if cfg.DatabaseURL == "" {
		return nil, fmt.Errorf("DATABASE_URL must not be empty")
	}
	if cfg.Concurrency < 1 {
		cfg.Concurrency = 1
	}
	if cfg.MaxPages < 0 {
		cfg.MaxPages = 0
	}
	if cfg.IncrementalPages < 1 {
		cfg.IncrementalPages = 1
	}
	if cfg.FetchConcurrency < 1 {
		cfg.FetchConcurrency = 1
	}
	if cfg.FetchConcurrency > 32 {
		cfg.FetchConcurrency = 32
	}
	if cfg.ListConcurrency < 1 {
		cfg.ListConcurrency = 1
	}
	if cfg.ListConcurrency > 16 {
		cfg.ListConcurrency = 16
	}
	if cfg.JobLease < 5*time.Second {
		cfg.JobLease = 5 * time.Second
	}
	if cfg.JobLease > 30*time.Minute {
		cfg.JobLease = 30 * time.Minute
	}
	if cfg.Production() && cfg.AllowInsecure {
		return nil, fmt.Errorf(
			"COLLECTOR_ALLOW_INSECURE is not allowed when APP_ENV=%s",
			cfg.Environment,
		)
	}
	return cfg, nil
}

// Production reports whether this is a production-like environment.
func (c *Config) Production() bool {
	return c.Environment != "development" && c.Environment != "test" && c.Environment != "local"
}
