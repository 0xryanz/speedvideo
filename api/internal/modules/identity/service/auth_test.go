package service

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/pagefau1t/speedvideo/api/internal/modules/identity/domain"
	"github.com/pagefau1t/speedvideo/api/internal/platform/apperr"
	"github.com/pagefau1t/speedvideo/api/internal/platform/security"
)

type memoryUsers struct {
	byEmail  map[string]*domain.User
	byID     map[string]*domain.User
	profiles *memoryProfiles
}

func newMemoryUsers() *memoryUsers {
	return &memoryUsers{byEmail: map[string]*domain.User{}, byID: map[string]*domain.User{}}
}

func (m *memoryUsers) FindByEmail(_ context.Context, email string) (*domain.User, error) {
	user, ok := m.byEmail[email]
	if !ok {
		return nil, apperr.New(apperr.KindNotFound, "account not found")
	}
	return user, nil
}

func (m *memoryUsers) FindByID(_ context.Context, id string) (*domain.User, error) {
	user, ok := m.byID[id]
	if !ok {
		return nil, apperr.New(apperr.KindNotFound, "account not found")
	}
	return user, nil
}

func (m *memoryUsers) CreateWithProfile(
	_ context.Context,
	user *domain.User,
	profile *domain.Profile,
) error {
	user.ID = uuid.NewString()
	user.CreatedAt = time.Now().UTC()
	profile.ID = uuid.NewString()
	profile.UserID = user.ID
	m.byEmail[user.Email] = user
	m.byID[user.ID] = user
	if m.profiles != nil {
		m.profiles.byID[profile.ID] = profile
	}
	return nil
}

type memoryProfiles struct {
	byID map[string]*domain.Profile
}

func newMemoryProfiles() *memoryProfiles {
	return &memoryProfiles{byID: map[string]*domain.Profile{}}
}

func (m *memoryProfiles) ListByUser(_ context.Context, userID string) ([]domain.Profile, error) {
	out := make([]domain.Profile, 0)
	for _, profile := range m.byID {
		if profile.UserID == userID {
			out = append(out, *profile)
		}
	}
	return out, nil
}

func (m *memoryProfiles) FindByIDAndUser(
	_ context.Context,
	id, userID string,
) (*domain.Profile, error) {
	profile, ok := m.byID[id]
	if !ok || profile.UserID != userID {
		return nil, apperr.New(apperr.KindNotFound, "profile not found")
	}
	return profile, nil
}

func (m *memoryProfiles) CountByUser(context.Context, string) (int64, error) { return 1, nil }
func (m *memoryProfiles) Create(_ context.Context, profile *domain.Profile) error {
	if profile.ID == "" {
		profile.ID = uuid.NewString()
	}
	m.byID[profile.ID] = profile
	return nil
}
func (m *memoryProfiles) Update(context.Context, *domain.Profile) error { return nil }
func (m *memoryProfiles) Delete(_ context.Context, profile *domain.Profile) error {
	delete(m.byID, profile.ID)
	return nil
}

type memoryRefresh struct {
	byID   map[string]*domain.RefreshToken
	byHash map[string]*domain.RefreshToken
}

func newMemoryRefresh() *memoryRefresh {
	return &memoryRefresh{
		byID:   map[string]*domain.RefreshToken{},
		byHash: map[string]*domain.RefreshToken{},
	}
}

func (m *memoryRefresh) Create(_ context.Context, token *domain.RefreshToken) error {
	if token.ID == "" {
		token.ID = uuid.NewString()
	}
	m.byID[token.ID] = token
	m.byHash[token.TokenHash] = token
	return nil
}

func (m *memoryRefresh) FindByHash(_ context.Context, hash string) (*domain.RefreshToken, error) {
	token, ok := m.byHash[hash]
	if !ok {
		return nil, apperr.New(apperr.KindUnauthorized, "refresh token is invalid")
	}
	return token, nil
}

func (m *memoryRefresh) Rotate(
	_ context.Context,
	oldID string,
	replacement *domain.RefreshToken,
) error {
	old, ok := m.byID[oldID]
	if !ok || old.RevokedAt != nil {
		return apperr.New(apperr.KindConflict, "already rotated")
	}
	now := time.Now().UTC()
	old.RevokedAt = &now
	old.ReplacedByID = &replacement.ID
	if err := m.Create(context.Background(), replacement); err != nil {
		return err
	}
	return nil
}

func (m *memoryRefresh) RevokeFamily(_ context.Context, familyID string) error {
	now := time.Now().UTC()
	for _, token := range m.byID {
		if token.FamilyID == familyID && token.RevokedAt == nil {
			token.RevokedAt = &now
		}
	}
	return nil
}

func (m *memoryRefresh) RevokeByProfile(context.Context, string) error { return nil }
func (m *memoryRefresh) Revoke(context.Context, string) error          { return nil }
func (m *memoryRefresh) UpdateProfile(_ context.Context, id, profileID string) error {
	token, ok := m.byID[id]
	if !ok {
		return apperr.New(apperr.KindNotFound, "token not found")
	}
	token.ProfileID = &profileID
	return nil
}
func (m *memoryRefresh) DeleteExpired(context.Context, time.Time) (int64, error) { return 0, nil }

func newAuthFixture(
	t *testing.T,
) (*AuthService, *memoryUsers, *memoryProfiles, *memoryRefresh, *security.TokenManager) {
	t.Helper()
	users := newMemoryUsers()
	profiles := newMemoryProfiles()
	users.profiles = profiles
	refresh := newMemoryRefresh()
	manager := security.NewTokenManager("0123456789abcdef0123456789abcdef", "test", 15*time.Minute)
	svc, err := NewAuthService(users, profiles, refresh, manager, time.Hour)
	require.NoError(t, err)
	return svc, users, profiles, refresh, manager
}

func TestRegisterAndLogin(t *testing.T) {
	svc, _, profiles, _, _ := newAuthFixture(t)
	session, err := svc.Register(
		context.Background(),
		"USER@Example.com ",
		"Password123!",
		"Ada",
		ClientMeta{UserAgent: "test"},
	)
	require.NoError(t, err)
	require.Equal(t, "user@example.com", session.User.Email)
	require.Empty(t, session.ActiveProfileID)
	require.Len(t, session.Profiles, 1)
	require.NotEmpty(t, session.AccessToken)

	stored, err := profiles.ListByUser(context.Background(), session.User.ID)
	require.NoError(t, err)
	require.Len(t, stored, 1)
	require.Equal(t, "Ada", stored[0].Name)

	login, err := svc.Login(context.Background(), "user@example.com", "Password123!", ClientMeta{})
	require.NoError(t, err)
	require.Equal(t, session.User.ID, login.User.ID)

	_, err = svc.Login(context.Background(), "user@example.com", "wrong-password", ClientMeta{})
	require.Error(t, err)
}

func TestRegisterFallsBackToMemberProfileName(t *testing.T) {
	svc, _, profiles, _, _ := newAuthFixture(t)
	session, err := svc.Register(
		context.Background(),
		"nameless@example.com",
		"Password123!",
		"",
		ClientMeta{},
	)
	require.NoError(t, err)
	stored, err := profiles.ListByUser(context.Background(), session.User.ID)
	require.NoError(t, err)
	require.Len(t, stored, 1)
	require.Equal(t, "Member", stored[0].Name)
}

func TestRefreshRotationDetectsReuse(t *testing.T) {
	svc, _, _, _, _ := newAuthFixture(t)
	session, err := svc.Register(
		context.Background(),
		"user@example.com",
		"Password123!",
		"",
		ClientMeta{},
	)
	require.NoError(t, err)

	rotated, err := svc.Refresh(context.Background(), session.RefreshToken, ClientMeta{})
	require.NoError(t, err)
	require.NotEqual(t, session.RefreshToken, rotated.RefreshToken)
	require.Equal(t, session.User.ID, rotated.User.ID)

	// Replaying the consumed token must fail and revoke the new token too.
	_, err = svc.Refresh(context.Background(), session.RefreshToken, ClientMeta{})
	require.Error(t, err)
	require.True(t, apperr.IsKind(err, apperr.KindUnauthorized))

	_, err = svc.Refresh(context.Background(), rotated.RefreshToken, ClientMeta{})
	require.Error(t, err)
}

func TestSelectProfileScopesTokens(t *testing.T) {
	svc, _, profiles, _, manager := newAuthFixture(t)
	session, err := svc.Register(
		context.Background(),
		"user@example.com",
		"Password123!",
		"",
		ClientMeta{},
	)
	require.NoError(t, err)
	list, err := profiles.ListByUser(context.Background(), session.User.ID)
	require.NoError(t, err)

	selected, err := svc.SelectProfile(
		context.Background(),
		session.User.ID,
		list[0].ID,
		session.RefreshToken,
	)
	require.NoError(t, err)
	require.Equal(t, list[0].ID, selected.ActiveProfileID)

	claims, err := manager.Parse(selected.AccessToken)
	require.NoError(t, err)
	require.Equal(t, list[0].ID, claims.ProfileID)
}
