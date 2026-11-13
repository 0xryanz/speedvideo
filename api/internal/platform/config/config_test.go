package config

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestLoadDefaultsInDevelopment(t *testing.T) {
	t.Setenv("APP_ENV", "development")
	cfg, err := Load()
	require.NoError(t, err)
	require.Equal(t, "development", cfg.Environment)
	require.Equal(t, "http://localhost:8080", cfg.PublicBaseURL)
	require.Equal(t, 5, cfg.MaxProfiles)
}

func TestProductionRejectsDevelopmentSecrets(t *testing.T) {
	t.Setenv("APP_ENV", "production")
	t.Setenv("JWT_SECRET", "dev-only-jwt-secret-change-me-please-32")
	t.Setenv("MEDIA_SIGNING_KEY", "0123456789abcdef0123456789abcdef")
	t.Setenv("PUBLIC_BASE_URL", "https://api.speedvideo.example")
	t.Setenv("CORS_ALLOWED_ORIGINS", "https://speedvideo.example")

	_, err := Load()
	require.ErrorContains(t, err, "development secrets")
}

func TestProductionRejectsInsecurePublicURLAndWildcardCORS(t *testing.T) {
	t.Setenv("APP_ENV", "production")
	t.Setenv("JWT_SECRET", "0123456789abcdef0123456789abcdef")
	t.Setenv("MEDIA_SIGNING_KEY", "0123456789abcdef0123456789abcdef")
	t.Setenv("PUBLIC_BASE_URL", "http://api.speedvideo.example")
	t.Setenv("CORS_ALLOWED_ORIGINS", "https://speedvideo.example")
	_, err := Load()
	require.ErrorContains(t, err, "https")

	t.Setenv("PUBLIC_BASE_URL", "https://api.speedvideo.example")
	t.Setenv("CORS_ALLOWED_ORIGINS", "*")
	_, err = Load()
	require.ErrorContains(t, err, "wildcard")
}

func TestProductionAcceptsHardenedValues(t *testing.T) {
	t.Setenv("APP_ENV", "production")
	t.Setenv("JWT_SECRET", "0123456789abcdef0123456789abcdef")
	t.Setenv("MEDIA_SIGNING_KEY", "fedcba9876543210fedcba9876543210")
	t.Setenv("PUBLIC_BASE_URL", "https://api.speedvideo.example")
	t.Setenv("CORS_ALLOWED_ORIGINS", "https://speedvideo.example")
	cfg, err := Load()
	require.NoError(t, err)
	require.True(t, cfg.Production())
}

func TestProductionRejectsInsecureContentSources(t *testing.T) {
	t.Setenv("APP_ENV", "production")
	t.Setenv("JWT_SECRET", "0123456789abcdef0123456789abcdef")
	t.Setenv("MEDIA_SIGNING_KEY", "0123456789abcdef0123456789abcdef")
	t.Setenv("PUBLIC_BASE_URL", "https://api.speedvideo.example")
	t.Setenv("CORS_ALLOWED_ORIGINS", "https://speedvideo.example")
	t.Setenv("SOURCE_ALLOW_INSECURE", "true")

	_, err := Load()
	require.ErrorContains(t, err, "SOURCE_ALLOW_INSECURE")
}
