package security

import (
	"strings"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

func TestPasswordHashing(t *testing.T) {
	hash, err := HashPassword("correct horse battery staple")
	require.NoError(t, err)
	require.True(t, strings.HasPrefix(hash, "$argon2id$"))
	require.NotContains(t, hash, "correct horse")

	match, err := VerifyPassword("correct horse battery staple", hash)
	require.NoError(t, err)
	require.True(t, match)

	match, err = VerifyPassword("wrong", hash)
	require.NoError(t, err)
	require.False(t, match)
}

func TestAccessTokenRoundTrip(t *testing.T) {
	manager := NewTokenManager("0123456789abcdef0123456789abcdef", "test-issuer", time.Minute)
	token, expiresAt, err := manager.Issue("user-1", "profile-1", true)
	require.NoError(t, err)
	require.True(t, expiresAt.After(time.Now()))

	claims, err := manager.Parse(token)
	require.NoError(t, err)
	require.Equal(t, "user-1", claims.UserID)
	require.Equal(t, "profile-1", claims.ProfileID)
	require.True(t, claims.IsKids)
}

func TestAccessTokenRejectsTamperingAndExpiry(t *testing.T) {
	manager := NewTokenManager("0123456789abcdef0123456789abcdef", "test-issuer", time.Minute)
	token, _, err := manager.Issue("user-1", "", false)
	require.NoError(t, err)

	parts := strings.Split(token, ".")
	require.Len(t, parts, 3)
	parts[2] = "AAAA" + parts[2][4:]
	_, err = manager.Parse(strings.Join(parts, "."))
	require.Error(t, err)

	short := NewTokenManager("0123456789abcdef0123456789abcdef", "test-issuer", -10*time.Second)
	expired, _, err := short.Issue("user-1", "", false)
	require.NoError(t, err)
	_, err = short.Parse(expired)
	require.Error(t, err)
}

func TestOpaqueTokensAreUniqueAndHashed(t *testing.T) {
	first, err := NewOpaqueToken()
	require.NoError(t, err)
	second, err := NewOpaqueToken()
	require.NoError(t, err)
	require.NotEqual(t, first, second)
	require.NotEqual(t, first, HashToken(first))
	require.Equal(t, HashToken(first), HashToken(first))
	require.Len(t, HashToken(first), 64)
}
