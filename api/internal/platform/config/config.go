package config

import (
	"fmt"
	"strings"
	"time"

	"github.com/caarlos0/env/v11"
)

// Config is the complete, environment-driven configuration for the API.
// Every value has a development default; production values are supplied by the
// platform (Docker Compose, Kubernetes, a secret manager) and validated below.
type Config struct {
	Environment       string        `env:"APP_ENV"               envDefault:"development"`
	HTTPAddr          string        `env:"HTTP_ADDR"             envDefault:":8080"`
	ReadTimeout       time.Duration `env:"HTTP_READ_TIMEOUT"     envDefault:"10s"`
	WriteTimeout      time.Duration `env:"HTTP_WRITE_TIMEOUT"    envDefault:"20s"`
	IdleTimeout       time.Duration `env:"HTTP_IDLE_TIMEOUT"     envDefault:"120s"`
	ShutdownTimeout   time.Duration `env:"HTTP_SHUTDOWN_TIMEOUT" envDefault:"20s"`
	DatabaseURL       string        `env:"DATABASE_URL"          envDefault:"postgres://speedvideo:speedvideo@localhost:5432/speedvideo?sslmode=disable"`
	DBMaxOpenConns    int           `env:"DB_MAX_OPEN_CONNS"     envDefault:"20"`
	DBMaxIdleConns    int           `env:"DB_MAX_IDLE_CONNS"     envDefault:"5"`
	DBConnMaxLife     time.Duration `env:"DB_CONN_MAX_LIFETIME"  envDefault:"30m"`
	AutoMigrate       bool          `env:"AUTO_MIGRATE"          envDefault:"true"`
	JWTSecret         string        `env:"JWT_SECRET"            envDefault:"dev-only-jwt-secret-change-me-please-32"`
	JWTIssuer         string        `env:"JWT_ISSUER"            envDefault:"speedvideo-api"`
	AccessTokenTTL    time.Duration `env:"ACCESS_TOKEN_TTL"      envDefault:"15m"`
	RefreshTokenTTL   time.Duration `env:"REFRESH_TOKEN_TTL"     envDefault:"720h"`
	MediaSigningKey   string        `env:"MEDIA_SIGNING_KEY"     envDefault:"dev-only-media-signing-key-change-me"`
	PlaybackTokenTTL  time.Duration `env:"PLAYBACK_TOKEN_TTL"    envDefault:"1h"`
	DownloadTokenTTL  time.Duration `env:"DOWNLOAD_TOKEN_TTL"    envDefault:"2h"`
	PublicBaseURL     string        `env:"PUBLIC_BASE_URL"       envDefault:"http://localhost:8080"`
	AllowedOrigins    []string      `env:"CORS_ALLOWED_ORIGINS"  envDefault:"*"                                                                           envSeparator:","`
	TrustProxy        bool          `env:"TRUST_PROXY_HEADERS"   envDefault:"false"`
	MaxProfiles       int           `env:"MAX_PROFILES"          envDefault:"5"`
	AllowedMediaHosts []string      `env:"ALLOWED_MEDIA_HOSTS"   envDefault:"test-streams.mux.dev,devstreaming-cdn.apple.com,stream.mux.com,media.w3.org" envSeparator:","`
	// SourceAllowInsecure relaxes the https requirement for content-source
	// endpoints and media so a local fixture can be exercised end to end. It is
	// rejected outside development.
	SourceAllowInsecure bool `env:"SOURCE_ALLOW_INSECURE" envDefault:"false"`
	// AdminAPIToken guards the collection control plane. It is held by the
	// admin console's reverse proxy, never by a browser. When empty the admin
	// routes are not mounted at all.
	AdminAPIToken string `env:"ADMIN_API_TOKEN"`
	LogLevel      string `env:"LOG_LEVEL"             envDefault:"info"`
}

// Load reads configuration from the environment and validates it.
func Load() (*Config, error) {
	cfg := &Config{}
	if err := env.Parse(cfg); err != nil {
		return nil, fmt.Errorf("parse environment: %w", err)
	}
	cfg.Environment = strings.ToLower(strings.TrimSpace(cfg.Environment))
	cfg.PublicBaseURL = strings.TrimRight(cfg.PublicBaseURL, "/")
	if err := cfg.validate(); err != nil {
		return nil, err
	}
	return cfg, nil
}

func (c *Config) validate() error {
	if c.Environment == "" {
		return fmt.Errorf("APP_ENV must not be empty")
	}
	if c.DatabaseURL == "" {
		return fmt.Errorf("DATABASE_URL must not be empty")
	}
	if len(c.JWTSecret) < 32 {
		return fmt.Errorf("JWT_SECRET must be at least 32 characters")
	}
	if len(c.MediaSigningKey) < 32 {
		return fmt.Errorf("MEDIA_SIGNING_KEY must be at least 32 characters")
	}
	if c.MaxProfiles < 1 {
		return fmt.Errorf("MAX_PROFILES must be positive")
	}
	if c.Production() {
		if strings.HasPrefix(c.JWTSecret, "dev-only") ||
			strings.HasPrefix(c.MediaSigningKey, "dev-only") {
			return fmt.Errorf("development secrets are not allowed when APP_ENV=%s", c.Environment)
		}
		if !strings.HasPrefix(c.PublicBaseURL, "https://") {
			return fmt.Errorf("PUBLIC_BASE_URL must use https in production")
		}
		for _, origin := range c.AllowedOrigins {
			if origin == "*" {
				return fmt.Errorf("wildcard CORS origin is not allowed in production")
			}
		}
		if len(c.AllowedMediaHosts) == 0 {
			return fmt.Errorf("ALLOWED_MEDIA_HOSTS must not be empty in production")
		}
		if c.SourceAllowInsecure {
			return fmt.Errorf("SOURCE_ALLOW_INSECURE is not allowed when APP_ENV=%s", c.Environment)
		}
	}
	return nil
}

// Production reports whether this process runs in a production-like
// environment (production, staging and any custom named deployment).
func (c *Config) Production() bool {
	return c.Environment != "development" && c.Environment != "test" && c.Environment != "local"
}
