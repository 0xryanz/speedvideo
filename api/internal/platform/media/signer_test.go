package media

import (
	"strings"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

func TestSignAndVerifyPlaybackClaims(t *testing.T) {
	signer := NewSigner("0123456789abcdef0123456789abcdef")
	claims := PlaybackClaims{
		URL:       "https://cdn.example/master.m3u8",
		TitleID:   "title-1",
		EpisodeID: "ep-1",
		ProfileID: "profile-1",
		ExpiresAt: time.Now().Add(time.Minute).Unix(),
	}
	token, err := signer.Sign(claims)
	require.NoError(t, err)
	require.False(t, strings.Contains(token, " "))
	require.Len(t, strings.Split(token, "."), 2)

	verified, err := signer.Verify(token, time.Now())
	require.NoError(t, err)
	require.Equal(t, claims.URL, verified.URL)
	require.Equal(t, claims.TitleID, verified.TitleID)
	require.Equal(t, claims.ProfileID, verified.ProfileID)
}

func TestVerifyRejectsTamperingAndExpiry(t *testing.T) {
	signer := NewSigner("0123456789abcdef0123456789abcdef")
	claims := PlaybackClaims{
		URL: "https://cdn.example/master.m3u8", TitleID: "t", ProfileID: "p",
		ExpiresAt: time.Now().Add(time.Minute).Unix(),
	}
	token, err := signer.Sign(claims)
	require.NoError(t, err)

	tampered := token[:len(token)-2] + "aa"
	_, err = signer.Verify(tampered, time.Now())
	require.Error(t, err)

	expired, err := signer.Sign(PlaybackClaims{
		URL: "https://cdn.example/master.m3u8", TitleID: "t", ProfileID: "p",
		ExpiresAt: time.Now().Add(-time.Second).Unix(),
	})
	require.NoError(t, err)
	_, err = signer.Verify(expired, time.Now())
	require.Error(t, err)
}

func TestVerifyRejectsMissingClaims(t *testing.T) {
	signer := NewSigner("0123456789abcdef0123456789abcdef")
	token, err := signer.Sign(PlaybackClaims{ExpiresAt: time.Now().Add(time.Minute).Unix()})
	require.NoError(t, err)
	_, err = signer.Verify(token, time.Now())
	require.Error(t, err)
}

func TestAllowlistRejectsNonHTTPSAndUnknownHosts(t *testing.T) {
	list := NewAllowlist([]string{"Media.Example.com"})

	if err := list.Check("https://media.example.com/movie.mp4"); err != nil {
		t.Fatalf("expected allow-listed host: %v", err)
	}
	if err := list.Check("http://media.example.com/movie.mp4"); err == nil {
		t.Fatal("expected http to be rejected")
	}
	if err := list.Check("https://evil.example.net/movie.mp4"); err == nil {
		t.Fatal("expected unknown host to be rejected")
	}
}
