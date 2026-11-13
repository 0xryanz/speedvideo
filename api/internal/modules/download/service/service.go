// Package service issues short-lived, signed grants for offline downloads.
// The upstream file URL never reaches the client; the download endpoint
// redirects to it only after the grant has been verified.
package service

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/pagefau1t/speedvideo/api/internal/modules/catalog/contracts"
	"github.com/pagefau1t/speedvideo/api/internal/platform/apperr"
	"github.com/pagefau1t/speedvideo/api/internal/platform/media"
)

// SourceReader resolves an entitled downloadable rendition.
type SourceReader interface {
	DownloadSource(
		ctx context.Context,
		titleID, episodeID string,
		kids bool,
	) (*contracts.DownloadSource, error)
}

// Download is the client-facing offline download session.
type Download struct {
	DownloadURL     string                `json:"download_url"`
	ExpiresAt       time.Time             `json:"expires_at"`
	TitleID         string                `json:"title_id"`
	TitleName       string                `json:"title_name"`
	FileName        string                `json:"file_name"`
	Episode         *contracts.EpisodeRef `json:"episode,omitempty"`
	PosterPath      string                `json:"poster_path"`
	BackdropPath    string                `json:"backdrop_path"`
	DurationSeconds int                   `json:"duration_seconds"`
}

// Service creates and verifies download grants.
type Service struct {
	sources    SourceReader
	signer     *media.Signer
	tokenTTL   time.Duration
	publicBase string
	allowlist  *media.Allowlist
}

// New builds the download service.
func New(
	sources SourceReader,
	signer *media.Signer,
	tokenTTL time.Duration,
	publicBase string,
	allowedHosts []string,
) *Service {
	return &Service{
		sources:    sources,
		signer:     signer,
		tokenTTL:   tokenTTL,
		publicBase: strings.TrimRight(publicBase, "/"),
		allowlist:  media.NewAllowlist(allowedHosts),
	}
}

// Create signs a download grant for the requested title/episode.
func (s *Service) Create(
	ctx context.Context,
	titleID, episodeID, profileID string,
	kids bool,
) (*Download, error) {
	source, err := s.sources.DownloadSource(ctx, titleID, episodeID, kids)
	if err != nil {
		return nil, err
	}
	if err := s.allowlist.Check(source.FileURL); err != nil {
		return nil, fmt.Errorf("configured download is not allowed: %w", err)
	}

	if source.Episode != nil {
		episodeID = source.Episode.ID
	}

	expiresAt := time.Now().UTC().Add(s.tokenTTL)
	token, err := s.signer.Sign(media.PlaybackClaims{
		URL:       source.FileURL,
		TitleID:   source.TitleID,
		EpisodeID: episodeID,
		ProfileID: profileID,
		Scope:     media.ScopeDownload,
		ExpiresAt: expiresAt.Unix(),
	})
	if err != nil {
		return nil, fmt.Errorf("sign download token: %w", err)
	}

	return &Download{
		DownloadURL:     s.publicBase + "/v1/downloads/file/" + token,
		ExpiresAt:       expiresAt,
		TitleID:         source.TitleID,
		TitleName:       source.TitleName,
		FileName:        source.FileName,
		Episode:         source.Episode,
		PosterPath:      source.PosterPath,
		BackdropPath:    source.BackdropPath,
		DurationSeconds: source.RuntimeSeconds,
	}, nil
}

// Resolve verifies a signed grant and returns the upstream file URL.
func (s *Service) Resolve(token string) (string, error) {
	claims, err := s.signer.Verify(token, time.Now().UTC())
	if err != nil || !claims.AllowsScope(media.ScopeDownload) {
		return "", apperr.New(apperr.KindUnauthorized, "download link is invalid or expired")
	}
	if err := s.allowlist.Check(claims.URL); err != nil {
		return "", apperr.New(apperr.KindForbidden, "download host is not allowed")
	}
	return claims.URL, nil
}
