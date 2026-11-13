package service_test

import (
	"context"
	"strings"
	"testing"
	"time"

	"github.com/pagefau1t/speedvideo/api/internal/modules/catalog/contracts"
	downloadservice "github.com/pagefau1t/speedvideo/api/internal/modules/download/service"
	"github.com/pagefau1t/speedvideo/api/internal/platform/apperr"
	"github.com/pagefau1t/speedvideo/api/internal/platform/media"
)

const (
	testKey      = "0123456789abcdef0123456789abcdef"
	testFileURL  = "https://media.example.com/inception.mp4"
	testBaseURL  = "https://api.example.com"
	testProfile  = "profile-1"
	testTitle    = "title-1"
	testEpisode  = "episode-1"
	testFileName = "inception-s01e02.mp4"
)

type stubSource struct {
	source *contracts.DownloadSource
	err    error
}

func (s stubSource) DownloadSource(
	_ context.Context,
	_, _ string,
	_ bool,
) (*contracts.DownloadSource, error) {
	return s.source, s.err
}

func newService(source *contracts.DownloadSource, ttl time.Duration) *downloadservice.Service {
	return downloadservice.New(
		stubSource{source: source},
		media.NewSigner(testKey),
		ttl,
		testBaseURL,
		[]string{"media.example.com"},
	)
}

func demoSource() *contracts.DownloadSource {
	return &contracts.DownloadSource{
		TitleID:        testTitle,
		TitleName:      "Inception",
		FileName:       testFileName,
		FileURL:        testFileURL,
		RuntimeSeconds: 8880,
		PosterPath:     "/static/posters/inception.jpg",
		Episode: &contracts.EpisodeRef{
			ID:           testEpisode,
			Number:       2,
			SeasonNumber: 1,
			Name:         "Episode 2",
		},
	}
}

func TestCreateSignsResolvableGrant(t *testing.T) {
	svc := newService(demoSource(), time.Hour)

	download, err := svc.Create(context.Background(), testTitle, testEpisode, testProfile, false)
	if err != nil {
		t.Fatalf("create: %v", err)
	}
	if download.TitleName != "Inception" || download.FileName != testFileName {
		t.Fatalf("unexpected payload: %+v", download)
	}
	if !strings.HasPrefix(download.DownloadURL, testBaseURL+"/v1/downloads/file/") {
		t.Fatalf("unexpected download url %q", download.DownloadURL)
	}
	if download.Episode == nil || download.Episode.ID != testEpisode {
		t.Fatalf("episode not carried through: %+v", download.Episode)
	}
	if !download.ExpiresAt.After(time.Now()) {
		t.Fatalf("grant should not be pre-expired: %v", download.ExpiresAt)
	}

	token := strings.TrimPrefix(download.DownloadURL, testBaseURL+"/v1/downloads/file/")
	resolved, err := svc.Resolve(token)
	if err != nil {
		t.Fatalf("resolve: %v", err)
	}
	if resolved != testFileURL {
		t.Fatalf("resolved %q, want %q", resolved, testFileURL)
	}
}

func TestResolveRejectsPlaybackScopedToken(t *testing.T) {
	signer := media.NewSigner(testKey)
	token, err := signer.Sign(media.PlaybackClaims{
		URL:       testFileURL,
		TitleID:   testTitle,
		ProfileID: testProfile,
		Scope:     media.ScopePlayback,
		ExpiresAt: time.Now().Add(time.Hour).Unix(),
	})
	if err != nil {
		t.Fatalf("sign: %v", err)
	}
	svc := newService(demoSource(), time.Hour)
	if _, err := svc.Resolve(token); err == nil {
		t.Fatal("expected playback token to be rejected by the download endpoint")
	}
}

func TestResolveRejectsExpiredGrant(t *testing.T) {
	signer := media.NewSigner(testKey)
	token, err := signer.Sign(media.PlaybackClaims{
		URL:       testFileURL,
		TitleID:   testTitle,
		ProfileID: testProfile,
		Scope:     media.ScopeDownload,
		ExpiresAt: time.Now().Add(-time.Minute).Unix(),
	})
	if err != nil {
		t.Fatalf("sign: %v", err)
	}
	svc := newService(demoSource(), time.Hour)
	if _, err := svc.Resolve(token); err == nil {
		t.Fatal("expected expired token to be rejected")
	}
}

func TestCreateRejectsUnlistedDownloadHost(t *testing.T) {
	source := demoSource()
	source.FileURL = "https://evil.example.net/movie.mp4"
	svc := newService(source, time.Hour)

	if _, err := svc.Create(context.Background(), testTitle, "", testProfile, false); err == nil {
		t.Fatal("expected non-allow-listed host to fail")
	}
}

func TestCreatePropagatesMissingRendition(t *testing.T) {
	svc := downloadservice.New(
		stubSource{
			err: apperr.New(apperr.KindNotFound, "download is not available for this title"),
		},
		media.NewSigner(testKey),
		time.Hour,
		testBaseURL,
		[]string{"media.example.com"},
	)

	_, err := svc.Create(context.Background(), testTitle, "", testProfile, false)
	if !apperr.IsKind(err, apperr.KindNotFound) {
		t.Fatalf("expected not found, got %v", err)
	}
}
