// Package media implements short-lived signed playback URLs. The signing
// scheme is deliberately provider-agnostic: in production the same token can be
// verified at a CDN edge, while the local API validates it for demo streams.
package media

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"
)

// Token scopes keep playback and download grants from being interchangeable.
const (
	ScopePlayback = "playback"
	ScopeDownload = "download"
)

// PlaybackClaims describe a single entitled media grant.
type PlaybackClaims struct {
	URL       string `json:"u"`
	TitleID   string `json:"t"`
	EpisodeID string `json:"e,omitempty"`
	ProfileID string `json:"p"`
	Scope     string `json:"s,omitempty"`
	// SourceID binds the grant to an external content provider. Redeeming the
	// grant re-checks the provider's declared hosts, so disabling a provider
	// revokes access even for tokens that have not expired.
	SourceID  string `json:"src,omitempty"`
	ExpiresAt int64  `json:"x"`
}

// Signer issues and verifies HMAC-SHA256 playback tokens.
type Signer struct {
	key []byte
}

// NewSigner builds a signer from the deployment's media signing key.
func NewSigner(key string) *Signer {
	return &Signer{key: []byte(key)}
}

// Sign returns a compact payload.signature token. Both parts are base64url
// encoded without padding so the token is URL-safe.
func (s *Signer) Sign(claims PlaybackClaims) (string, error) {
	payload, err := json.Marshal(claims)
	if err != nil {
		return "", fmt.Errorf("marshal playback claims: %w", err)
	}
	encoded := base64.RawURLEncoding.EncodeToString(payload)
	signature := s.signature(encoded)
	return encoded + "." + signature, nil
}

// Verify validates the signature and expiry, then returns the claims.
func (s *Signer) Verify(token string, now time.Time) (*PlaybackClaims, error) {
	parts := strings.Split(token, ".")
	if len(parts) != 2 || parts[0] == "" || parts[1] == "" {
		return nil, errors.New("malformed playback token")
	}
	expected := s.signature(parts[0])
	if !hmac.Equal([]byte(expected), []byte(parts[1])) {
		return nil, errors.New("invalid playback token signature")
	}
	payload, err := base64.RawURLEncoding.DecodeString(parts[0])
	if err != nil {
		return nil, errors.New("invalid playback token payload")
	}
	claims := &PlaybackClaims{}
	if err := json.Unmarshal(payload, claims); err != nil {
		return nil, errors.New("invalid playback token payload")
	}
	if claims.ExpiresAt <= now.UTC().Unix() {
		return nil, errors.New("playback token expired")
	}
	if claims.URL == "" || claims.ProfileID == "" || claims.TitleID == "" {
		return nil, errors.New("playback token is missing required claims")
	}
	return claims, nil
}

// AllowsScope reports whether the token was minted for the requested use.
// Tokens without a scope predate scoping and are treated as playback grants.
func (c *PlaybackClaims) AllowsScope(scope string) bool {
	if c.Scope == "" {
		return scope == ScopePlayback
	}
	return c.Scope == scope
}

func (s *Signer) signature(encodedPayload string) string {
	mac := hmac.New(sha256.New, s.key)
	mac.Write([]byte(encodedPayload))
	return base64.RawURLEncoding.EncodeToString(mac.Sum(nil))
}
