// Package security contains authentication and signing primitives that are
// independent of HTTP and persistence.
package security

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"fmt"
	"time"

	"github.com/alexedwards/argon2id"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

// TokenAudience is embedded in and required by all access tokens.
const TokenAudience = "speedvideo-app"

// Claims are the access-token claims issued by the identity module.
type Claims struct {
	UserID    string `json:"-"`
	ProfileID string `json:"pid,omitempty"`
	IsKids    bool   `json:"kids,omitempty"`
	jwt.RegisteredClaims
}

// TokenManager signs and verifies short-lived access tokens.
type TokenManager struct {
	key      []byte
	issuer   string
	audience string
	ttl      time.Duration
}

// NewTokenManager builds a JWT manager. The secret must be supplied by the
// deployment environment and is validated by config.Load.
func NewTokenManager(secret, issuer string, ttl time.Duration) *TokenManager {
	return &TokenManager{
		key:      []byte(secret),
		issuer:   issuer,
		audience: TokenAudience,
		ttl:      ttl,
	}
}

// Issue creates an access token for a user, optionally scoped to a profile.
func (m *TokenManager) Issue(userID, profileID string, isKids bool) (string, time.Time, error) {
	now := time.Now().UTC()
	expiresAt := now.Add(m.ttl)
	claims := Claims{
		UserID:    userID,
		ProfileID: profileID,
		IsKids:    isKids,
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer:    m.issuer,
			Subject:   userID,
			Audience:  jwt.ClaimStrings{m.audience},
			ID:        uuid.NewString(),
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now.Add(-5 * time.Second)),
			ExpiresAt: jwt.NewNumericDate(expiresAt),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signed, err := token.SignedString(m.key)
	if err != nil {
		return "", time.Time{}, fmt.Errorf("sign access token: %w", err)
	}
	return signed, expiresAt, nil
}

// Parse validates an access token and returns its claims.
func (m *TokenManager) Parse(raw string) (*Claims, error) {
	claims := &Claims{}
	_, err := jwt.ParseWithClaims(raw, claims, func(token *jwt.Token) (any, error) {
		if token.Method != jwt.SigningMethodHS256 {
			return nil, fmt.Errorf("unexpected signing method %q", token.Method.Alg())
		}
		return m.key, nil
	},
		jwt.WithValidMethods([]string{jwt.SigningMethodHS256.Alg()}),
		jwt.WithIssuer(m.issuer),
		jwt.WithAudience(m.audience),
		jwt.WithExpirationRequired(),
		jwt.WithLeeway(5*time.Second),
	)
	if err != nil {
		return nil, fmt.Errorf("parse access token: %w", err)
	}
	if claims.Subject == "" {
		return nil, fmt.Errorf("access token is missing subject")
	}
	claims.UserID = claims.Subject
	return claims, nil
}

// HashPassword derives an Argon2id hash using library defaults (memory-hard,
// tuned for interactive logins).
func HashPassword(password string) (string, error) {
	hash, err := argon2id.CreateHash(password, argon2id.DefaultParams)
	if err != nil {
		return "", fmt.Errorf("hash password: %w", err)
	}
	return hash, nil
}

// VerifyPassword performs a constant-time password comparison.
func VerifyPassword(password, encodedHash string) (bool, error) {
	match, err := argon2id.ComparePasswordAndHash(password, encodedHash)
	if err != nil {
		return false, fmt.Errorf("verify password: %w", err)
	}
	return match, nil
}

// NewOpaqueToken creates a URL-safe, 256-bit random token suitable for refresh
// tokens. Only its hash is persisted.
func NewOpaqueToken() (string, error) {
	buf := make([]byte, 32)
	if _, err := rand.Read(buf); err != nil {
		return "", fmt.Errorf("generate random token: %w", err)
	}
	return base64.RawURLEncoding.EncodeToString(buf), nil
}

// HashToken returns the hex SHA-256 digest of an opaque token.
func HashToken(token string) string {
	sum := sha256.Sum256([]byte(token))
	return hex.EncodeToString(sum[:])
}
