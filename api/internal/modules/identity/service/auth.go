package service

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/pagefau1t/speedvideo/api/internal/modules/identity/domain"
	"github.com/pagefau1t/speedvideo/api/internal/platform/apperr"
	"github.com/pagefau1t/speedvideo/api/internal/platform/security"
)

// ClientMeta captures device context attached to refresh tokens.
type ClientMeta struct {
	UserAgent string
	IP        string
}

// Session is the result of a successful authentication or profile selection.
type Session struct {
	AccessToken     string
	RefreshToken    string
	ExpiresAt       time.Time
	User            *domain.User
	Profiles        []domain.Profile
	ActiveProfileID string
}

// AuthService owns registration, login, refresh rotation and profile scoping.
type AuthService struct {
	users      UserStore
	profiles   ProfileStore
	refresh    RefreshTokenStore
	tokens     *security.TokenManager
	refreshTTL time.Duration
	dummyHash  string
	now        func() time.Time
}

// NewAuthService wires the authentication use cases.
func NewAuthService(
	users UserStore,
	profiles ProfileStore,
	refresh RefreshTokenStore,
	tokens *security.TokenManager,
	refreshTTL time.Duration,
) (*AuthService, error) {
	dummyHash, err := security.HashPassword("timing-equalisation-placeholder")
	if err != nil {
		return nil, fmt.Errorf("prepare password verifier: %w", err)
	}
	return &AuthService{
		users:      users,
		profiles:   profiles,
		refresh:    refresh,
		tokens:     tokens,
		refreshTTL: refreshTTL,
		dummyHash:  dummyHash,
		now:        func() time.Time { return time.Now().UTC() },
	}, nil
}

// Register creates an account with a first profile and returns a signed-in
// account session.
func (s *AuthService) Register(
	ctx context.Context,
	email, password, displayName string,
	meta ClientMeta,
) (*Session, error) {
	email = normaliseEmail(email)
	displayName = strings.TrimSpace(displayName)
	if len(password) < 8 {
		return nil, apperr.New(apperr.KindValidation, "password must be at least 8 characters")
	}
	if displayName == "" {
		displayName = "Member"
	}
	hash, err := security.HashPassword(password)
	if err != nil {
		return nil, fmt.Errorf("hash password: %w", err)
	}
	user := &domain.User{
		Email:        email,
		PasswordHash: hash,
		DisplayName:  displayName,
		Plan:         "standard",
		Role:         "member",
	}
	profile := &domain.Profile{
		Name:             "You",
		AvatarColor:      "#E50914",
		IsKids:           false,
		Language:         "en",
		AutoplayNext:     true,
		AutoplayPreviews: true,
		MaturityRating:   "18+",
	}
	if err := s.users.CreateWithProfile(ctx, user, profile); err != nil {
		return nil, err
	}
	return s.issueAccountSession(ctx, user, []domain.Profile{*profile}, "", meta)
}

// Login verifies credentials and returns an account-scoped session. The caller
// must select a profile before accessing personalised endpoints.
func (s *AuthService) Login(
	ctx context.Context,
	email, password string,
	meta ClientMeta,
) (*Session, error) {
	email = normaliseEmail(email)
	user, err := s.users.FindByEmail(ctx, email)
	if err != nil {
		// Perform the same expensive comparison for unknown accounts so timing
		// does not disclose whether an email is registered.
		_, _ = security.VerifyPassword(password, s.dummyHash)
		if apperr.IsKind(err, apperr.KindNotFound) {
			return nil, apperr.New(apperr.KindUnauthorized, "invalid email or password")
		}
		return nil, err
	}
	match, err := security.VerifyPassword(password, user.PasswordHash)
	if err != nil {
		return nil, fmt.Errorf("verify password: %w", err)
	}
	if !match {
		return nil, apperr.New(apperr.KindUnauthorized, "invalid email or password")
	}
	profiles, err := s.profiles.ListByUser(ctx, user.ID)
	if err != nil {
		return nil, err
	}
	return s.issueAccountSession(ctx, user, profiles, "", meta)
}

// Refresh rotates a refresh token and issues a new access token. Reuse of an
// already-rotated token revokes the entire family.
func (s *AuthService) Refresh(
	ctx context.Context,
	rawToken string,
	meta ClientMeta,
) (*Session, error) {
	if rawToken == "" {
		return nil, apperr.New(apperr.KindUnauthorized, "refresh token is required")
	}
	existing, err := s.refresh.FindByHash(ctx, security.HashToken(rawToken))
	if err != nil {
		return nil, err
	}
	now := s.now()
	if existing.RevokedAt != nil {
		_ = s.refresh.RevokeFamily(ctx, existing.FamilyID)
		return nil, apperr.New(apperr.KindUnauthorized, "refresh token has been revoked")
	}
	if !now.Before(existing.ExpiresAt) {
		return nil, apperr.New(apperr.KindUnauthorized, "refresh token has expired")
	}

	nextRaw, next, err := s.buildRefreshToken(
		existing.UserID,
		profileValue(existing.ProfileID),
		existing.FamilyID,
		meta,
	)
	if err != nil {
		return nil, err
	}
	if err := s.refresh.Rotate(ctx, existing.ID, next); err != nil {
		if apperr.IsKind(err, apperr.KindConflict) {
			_ = s.refresh.RevokeFamily(ctx, existing.FamilyID)
			return nil, apperr.New(apperr.KindUnauthorized, "refresh token has been revoked")
		}
		return nil, err
	}

	user, err := s.users.FindByID(ctx, existing.UserID)
	if err != nil {
		return nil, err
	}
	profiles, err := s.profiles.ListByUser(ctx, user.ID)
	if err != nil {
		return nil, err
	}
	profileID, isKids := s.resolveScope(ctx, profileValue(existing.ProfileID), user.ID)
	accessToken, expiresAt, err := s.tokens.Issue(user.ID, profileID, isKids)
	if err != nil {
		return nil, err
	}
	return &Session{
		AccessToken:     accessToken,
		RefreshToken:    nextRaw,
		ExpiresAt:       expiresAt,
		User:            user,
		Profiles:        profiles,
		ActiveProfileID: profileID,
	}, nil
}

// Logout revokes the presented token's family. It is idempotent.
func (s *AuthService) Logout(ctx context.Context, rawToken string) error {
	if rawToken == "" {
		return nil
	}
	existing, err := s.refresh.FindByHash(ctx, security.HashToken(rawToken))
	if err != nil {
		if apperr.IsKind(err, apperr.KindUnauthorized) {
			return nil
		}
		return err
	}
	return s.refresh.RevokeFamily(ctx, existing.FamilyID)
}

// SelectProfile scopes a session to an existing profile and returns a fresh
// access token. The refresh token is retained so refresh keeps the selection.
func (s *AuthService) SelectProfile(
	ctx context.Context,
	userID, profileID, rawRefreshToken string,
) (*Session, error) {
	if rawRefreshToken == "" {
		return nil, apperr.New(apperr.KindUnauthorized, "refresh token is required")
	}
	existing, err := s.refresh.FindByHash(ctx, security.HashToken(rawRefreshToken))
	if err != nil {
		return nil, err
	}
	if existing.UserID != userID {
		return nil, apperr.New(
			apperr.KindForbidden,
			"refresh token does not belong to this account",
		)
	}
	if existing.RevokedAt != nil || !s.now().Before(existing.ExpiresAt) {
		return nil, apperr.New(apperr.KindUnauthorized, "refresh token is no longer valid")
	}
	profile, err := s.profiles.FindByIDAndUser(ctx, profileID, userID)
	if err != nil {
		return nil, err
	}
	if err := s.refresh.UpdateProfile(ctx, existing.ID, profile.ID); err != nil {
		return nil, err
	}
	user, err := s.users.FindByID(ctx, userID)
	if err != nil {
		return nil, err
	}
	profiles, err := s.profiles.ListByUser(ctx, userID)
	if err != nil {
		return nil, err
	}
	accessToken, expiresAt, err := s.tokens.Issue(user.ID, profile.ID, profile.IsKids)
	if err != nil {
		return nil, err
	}
	return &Session{
		AccessToken:     accessToken,
		RefreshToken:    rawRefreshToken,
		ExpiresAt:       expiresAt,
		User:            user,
		Profiles:        profiles,
		ActiveProfileID: profile.ID,
	}, nil
}

// CleanupExpired deletes refresh tokens that expired before the cutoff.
func (s *AuthService) CleanupExpired(ctx context.Context, before time.Time) (int64, error) {
	return s.refresh.DeleteExpired(ctx, before)
}

// User loads the authenticated account.
func (s *AuthService) User(ctx context.Context, id string) (*domain.User, error) {
	return s.users.FindByID(ctx, id)
}

func (s *AuthService) issueAccountSession(
	ctx context.Context,
	user *domain.User,
	profiles []domain.Profile,
	profileID string,
	meta ClientMeta,
) (*Session, error) {
	raw, token, err := s.buildRefreshToken(user.ID, profileID, "", meta)
	if err != nil {
		return nil, err
	}
	if err := s.refresh.Create(ctx, token); err != nil {
		return nil, err
	}
	isKids := false
	if profileID != "" {
		for _, profile := range profiles {
			if profile.ID == profileID {
				isKids = profile.IsKids
				break
			}
		}
	}
	accessToken, expiresAt, err := s.tokens.Issue(user.ID, profileID, isKids)
	if err != nil {
		return nil, err
	}
	return &Session{
		AccessToken:     accessToken,
		RefreshToken:    raw,
		ExpiresAt:       expiresAt,
		User:            user,
		Profiles:        profiles,
		ActiveProfileID: profileID,
	}, nil
}

func (s *AuthService) buildRefreshToken(
	userID, profileID, familyID string,
	meta ClientMeta,
) (string, *domain.RefreshToken, error) {
	raw, err := security.NewOpaqueToken()
	if err != nil {
		return "", nil, err
	}
	if familyID == "" {
		familyID = uuid.NewString()
	}
	var profileRef *string
	if profileID != "" {
		profileRef = &profileID
	}
	token := &domain.RefreshToken{
		UserID:    userID,
		ProfileID: profileRef,
		FamilyID:  familyID,
		TokenHash: security.HashToken(raw),
		ExpiresAt: s.now().Add(s.refreshTTL),
		UserAgent: truncate(meta.UserAgent, 512),
		IPAddress: truncate(meta.IP, 64),
	}
	return raw, token, nil
}

func (s *AuthService) resolveScope(ctx context.Context, profileID, userID string) (string, bool) {
	if profileID == "" {
		return "", false
	}
	profile, err := s.profiles.FindByIDAndUser(ctx, profileID, userID)
	if err != nil {
		return "", false
	}
	return profile.ID, profile.IsKids
}

func profileValue(value *string) string {
	if value == nil {
		return ""
	}
	return *value
}

func normaliseEmail(email string) string {
	return strings.ToLower(strings.TrimSpace(email))
}

func truncate(value string, limit int) string {
	if len(value) <= limit {
		return value
	}
	return value[:limit]
}
