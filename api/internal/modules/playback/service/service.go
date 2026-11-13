// Package service creates short-lived, signed playback sessions. It depends on
// narrow reader ports implemented by the catalog and library modules.
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

// SourceReader resolves an entitled upstream stream.
type SourceReader interface {
	PlaybackSource(
		ctx context.Context,
		titleID, episodeID string,
		kids bool,
	) (*contracts.PlaybackSource, error)
}

// ProgressReader supplies the viewer's resume position.
type ProgressReader interface {
	ProgressFor(ctx context.Context, profileID, titleID string) (*contracts.Progress, error)
}

// AudioTrack describes an available audio rendition.
type AudioTrack struct {
	Language string `json:"language"`
	Label    string `json:"label"`
	Default  bool   `json:"default"`
}

// SubtitleTrack describes an available subtitle rendition.
type SubtitleTrack struct {
	Language string `json:"language"`
	Label    string `json:"label"`
	Default  bool   `json:"default"`
}

// Playback is the client-facing playback session.
type Playback struct {
	ManifestURL           string                `json:"manifest_url"`
	ExpiresAt             time.Time             `json:"expires_at"`
	TitleID               string                `json:"title_id"`
	TitleName             string                `json:"title_name"`
	Episode               *contracts.EpisodeRef `json:"episode,omitempty"`
	PosterPath            string                `json:"poster_path"`
	BackdropPath          string                `json:"backdrop_path"`
	ResumePositionSeconds int                   `json:"resume_position_seconds"`
	DurationSeconds       int                   `json:"duration_seconds"`
	AudioTracks           []AudioTrack          `json:"audio_tracks"`
	SubtitleTracks        []SubtitleTrack       `json:"subtitle_tracks"`
}

// Service creates and verifies playback sessions.
type Service struct {
	sources    SourceReader
	progress   ProgressReader
	signer     *media.Signer
	tokenTTL   time.Duration
	publicBase string
	policy     *media.Policy
}

// New builds the playback service.
func New(
	sources SourceReader,
	progress ProgressReader,
	signer *media.Signer,
	tokenTTL time.Duration,
	publicBase string,
	policy *media.Policy,
) *Service {
	return &Service{
		sources:    sources,
		progress:   progress,
		signer:     signer,
		tokenTTL:   tokenTTL,
		publicBase: strings.TrimRight(publicBase, "/"),
		policy:     policy,
	}
}

// Create signs a playback session for the requested title/episode.
func (s *Service) Create(
	ctx context.Context,
	titleID, episodeID, profileID string,
	kids bool,
) (*Playback, error) {
	source, err := s.sources.PlaybackSource(ctx, titleID, episodeID, kids)
	if err != nil {
		return nil, err
	}
	if err := s.assertAllowed(ctx, source.VideoURL, source.SourceID); err != nil {
		return nil, fmt.Errorf("configured stream is not allowed: %w", err)
	}

	expiresAt := time.Now().UTC().Add(s.tokenTTL)
	claimsProfile := profileID
	if claimsProfile == "" {
		// Playback grants always carry a profile id; "guest" marks an
		// anonymous viewer and never reads or writes profile state.
		claimsProfile = "guest"
	}
	token, err := s.signer.Sign(media.PlaybackClaims{
		URL:       source.VideoURL,
		TitleID:   source.TitleID,
		EpisodeID: episodeID,
		ProfileID: claimsProfile,
		Scope:     media.ScopePlayback,
		SourceID:  source.SourceID,
		ExpiresAt: expiresAt.Unix(),
	})
	if err != nil {
		return nil, fmt.Errorf("sign playback token: %w", err)
	}

	resume := 0
	if s.progress != nil && profileID != "" {
		progress, err := s.progress.ProgressFor(ctx, profileID, titleID)
		if err != nil {
			return nil, fmt.Errorf("load resume position: %w", err)
		}
		if progress != nil && !progress.Completed {
			resume = progress.PositionSeconds
			if source.RuntimeSeconds > 0 && resume >= source.RuntimeSeconds-15 {
				resume = 0
			}
		}
	}

	return &Playback{
		ManifestURL:           s.publicBase + "/v1/playback/stream/" + token,
		ExpiresAt:             expiresAt,
		TitleID:               source.TitleID,
		TitleName:             source.TitleName,
		Episode:               source.Episode,
		PosterPath:            source.PosterPath,
		BackdropPath:          source.BackdropPath,
		ResumePositionSeconds: resume,
		DurationSeconds:       source.RuntimeSeconds,
		AudioTracks:           []AudioTrack{{Language: "en", Label: "English", Default: true}},
		SubtitleTracks:        []SubtitleTrack{},
	}, nil
}

// ResolveStream verifies a signed token and returns the upstream URL.
func (s *Service) ResolveStream(ctx context.Context, token string) (string, error) {
	claims, err := s.signer.Verify(token, time.Now().UTC())
	if err != nil {
		return "", apperr.New(apperr.KindUnauthorized, "playback link is invalid or expired")
	}
	if !claims.AllowsScope(media.ScopePlayback) {
		return "", apperr.New(apperr.KindUnauthorized, "playback link is invalid or expired")
	}
	if err := s.assertAllowed(ctx, claims.URL, claims.SourceID); err != nil {
		return "", apperr.New(apperr.KindForbidden, "playback host is not allowed")
	}
	return claims.URL, nil
}

func (s *Service) assertAllowed(ctx context.Context, raw, sourceID string) error {
	return s.policy.Check(ctx, raw, sourceID)
}
