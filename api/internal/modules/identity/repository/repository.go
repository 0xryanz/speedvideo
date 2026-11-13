// Package repository implements identity persistence with GORM.
package repository

import (
	"context"
	"errors"
	"fmt"
	"time"

	"gorm.io/gorm"

	"github.com/google/uuid"
	"github.com/pagefau1t/speedvideo/api/internal/modules/identity/domain"
	"github.com/pagefau1t/speedvideo/api/internal/platform/apperr"
)

// Repositories groups the identity module's persistence gateways.
type Repositories struct {
	Users         *UserRepository
	Profiles      *ProfileRepository
	RefreshTokens *RefreshTokenRepository
}

// New builds every identity repository from a single GORM handle.
func New(db *gorm.DB) *Repositories {
	return &Repositories{
		Users:         &UserRepository{db: db},
		Profiles:      &ProfileRepository{db: db},
		RefreshTokens: &RefreshTokenRepository{db: db},
	}
}

// UserRepository persists accounts.
type UserRepository struct {
	db *gorm.DB
}

// FindByEmail loads an account by normalised email.
func (r *UserRepository) FindByEmail(ctx context.Context, email string) (*domain.User, error) {
	var user domain.User
	if err := r.db.WithContext(ctx).Where("email = ?", email).First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, apperr.New(apperr.KindNotFound, "account not found")
		}
		return nil, fmt.Errorf("find user by email: %w", err)
	}
	return &user, nil
}

// FindByID loads an account by id.
func (r *UserRepository) FindByID(ctx context.Context, id string) (*domain.User, error) {
	var user domain.User
	if err := r.db.WithContext(ctx).Where("id = ?", id).First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, apperr.New(apperr.KindNotFound, "account not found")
		}
		return nil, fmt.Errorf("find user by id: %w", err)
	}
	return &user, nil
}

// ListAll returns every account, oldest first.
func (r *UserRepository) ListAll(ctx context.Context) ([]domain.User, error) {
	var users []domain.User
	if err := r.db.WithContext(ctx).Order("created_at ASC").Find(&users).Error; err != nil {
		return nil, fmt.Errorf("list accounts: %w", err)
	}
	return users, nil
}

// SetRole updates an account's role and reports whether a row changed.
func (r *UserRepository) SetRole(ctx context.Context, email, role string) error {
	result := r.db.WithContext(ctx).
		Model(&domain.User{}).
		Where("email = ?", email).
		Update("role", role)
	if result.Error != nil {
		return fmt.Errorf("update role: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return apperr.New(apperr.KindNotFound, "account not found")
	}
	return nil
}

// CreateWithProfile atomically creates an account and its first profile.
func (r *UserRepository) CreateWithProfile(
	ctx context.Context,
	user *domain.User,
	profile *domain.Profile,
) error {
	err := r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		if err := tx.Create(user).Error; err != nil {
			if errors.Is(err, gorm.ErrDuplicatedKey) {
				return apperr.New(apperr.KindConflict, "an account with this email already exists")
			}
			return err
		}
		profile.UserID = user.ID
		return tx.Create(profile).Error
	})
	if err != nil {
		if apperr.IsKind(err, apperr.KindConflict) {
			return err
		}
		return fmt.Errorf("create account: %w", err)
	}
	return nil
}

// ProfileRepository persists viewing profiles.
type ProfileRepository struct {
	db *gorm.DB
}

// ListByUser returns profiles in creation order.
func (r *ProfileRepository) ListByUser(
	ctx context.Context,
	userID string,
) ([]domain.Profile, error) {
	var profiles []domain.Profile
	if err := r.db.WithContext(ctx).Where("user_id = ?", userID).Order("created_at ASC").Find(&profiles).Error; err != nil {
		return nil, fmt.Errorf("list profiles: %w", err)
	}
	return profiles, nil
}

// FindByIDAndUser scopes a profile lookup to its owning account.
func (r *ProfileRepository) FindByIDAndUser(
	ctx context.Context,
	id, userID string,
) (*domain.Profile, error) {
	var profile domain.Profile
	if err := r.db.WithContext(ctx).Where("id = ? AND user_id = ?", id, userID).First(&profile).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, apperr.New(apperr.KindNotFound, "profile not found")
		}
		return nil, fmt.Errorf("find profile: %w", err)
	}
	return &profile, nil
}

// CountByUser returns how many profiles an account owns.
func (r *ProfileRepository) CountByUser(ctx context.Context, userID string) (int64, error) {
	var count int64
	if err := r.db.WithContext(ctx).Model(&domain.Profile{}).Where("user_id = ?", userID).Count(&count).Error; err != nil {
		return 0, fmt.Errorf("count profiles: %w", err)
	}
	return count, nil
}

// Create persists a new profile.
func (r *ProfileRepository) Create(ctx context.Context, profile *domain.Profile) error {
	if err := r.db.WithContext(ctx).Create(profile).Error; err != nil {
		return fmt.Errorf("create profile: %w", err)
	}
	return nil
}

// Update persists all mutable profile fields.
func (r *ProfileRepository) Update(ctx context.Context, profile *domain.Profile) error {
	if err := r.db.WithContext(ctx).Save(profile).Error; err != nil {
		return fmt.Errorf("update profile: %w", err)
	}
	return nil
}

// Delete removes a profile.
func (r *ProfileRepository) Delete(ctx context.Context, profile *domain.Profile) error {
	if err := r.db.WithContext(ctx).Delete(profile).Error; err != nil {
		return fmt.Errorf("delete profile: %w", err)
	}
	return nil
}

// RefreshTokenRepository persists hashed refresh tokens.
type RefreshTokenRepository struct {
	db *gorm.DB
}

// Create stores a refresh token hash.
func (r *RefreshTokenRepository) Create(ctx context.Context, token *domain.RefreshToken) error {
	if err := r.db.WithContext(ctx).Create(token).Error; err != nil {
		return fmt.Errorf("create refresh token: %w", err)
	}
	return nil
}

// FindByHash loads a token by its SHA-256 hash, including revoked tokens so the
// service can detect reuse.
func (r *RefreshTokenRepository) FindByHash(
	ctx context.Context,
	hash string,
) (*domain.RefreshToken, error) {
	var token domain.RefreshToken
	if err := r.db.WithContext(ctx).Where("token_hash = ?", hash).First(&token).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, apperr.New(apperr.KindUnauthorized, "refresh token is invalid")
		}
		return nil, fmt.Errorf("find refresh token: %w", err)
	}
	return &token, nil
}

// Rotate atomically revokes oldID and stores its replacement. It fails with
// KindConflict if the token was already rotated, which the service treats as
// reuse and escalates to a family-wide revocation.
func (r *RefreshTokenRepository) Rotate(
	ctx context.Context,
	oldID string,
	replacement *domain.RefreshToken,
) error {
	if replacement.ID == "" {
		replacement.ID = uuid.NewString()
	}
	err := r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		now := time.Now().UTC()
		result := tx.Model(&domain.RefreshToken{}).
			Where("id = ? AND revoked_at IS NULL", oldID).
			Updates(map[string]any{"revoked_at": now, "replaced_by_id": replacement.ID, "updated_at": now})
		if result.Error != nil {
			return result.Error
		}
		if result.RowsAffected != 1 {
			return apperr.New(apperr.KindConflict, "refresh token was already used")
		}
		return tx.Create(replacement).Error
	})
	if err != nil {
		if apperr.IsKind(err, apperr.KindConflict) {
			return err
		}
		return fmt.Errorf("rotate refresh token: %w", err)
	}
	return nil
}

// RevokeFamily revokes every token in a rotation family.
func (r *RefreshTokenRepository) RevokeFamily(ctx context.Context, familyID string) error {
	now := time.Now().UTC()
	if err := r.db.WithContext(ctx).Model(&domain.RefreshToken{}).
		Where("family_id = ? AND revoked_at IS NULL", familyID).
		Updates(map[string]any{"revoked_at": now, "updated_at": now}).Error; err != nil {
		return fmt.Errorf("revoke refresh token family: %w", err)
	}
	return nil
}

// RevokeByProfile revokes all tokens scoped to a deleted profile.
func (r *RefreshTokenRepository) RevokeByProfile(ctx context.Context, profileID string) error {
	now := time.Now().UTC()
	if err := r.db.WithContext(ctx).Model(&domain.RefreshToken{}).
		Where("profile_id = ? AND revoked_at IS NULL", profileID).
		Updates(map[string]any{"revoked_at": now, "updated_at": now}).Error; err != nil {
		return fmt.Errorf("revoke profile refresh tokens: %w", err)
	}
	return nil
}

// Revoke revokes a single token.
func (r *RefreshTokenRepository) Revoke(ctx context.Context, id string) error {
	now := time.Now().UTC()
	if err := r.db.WithContext(ctx).Model(&domain.RefreshToken{}).
		Where("id = ? AND revoked_at IS NULL", id).
		Updates(map[string]any{"revoked_at": now, "updated_at": now}).Error; err != nil {
		return fmt.Errorf("revoke refresh token: %w", err)
	}
	return nil
}

// UpdateProfile scopes an active token to a profile without rotating it, so the
// next access-token refresh keeps the selection.
func (r *RefreshTokenRepository) UpdateProfile(ctx context.Context, id, profileID string) error {
	if err := r.db.WithContext(ctx).Model(&domain.RefreshToken{}).
		Where("id = ? AND revoked_at IS NULL", id).
		Updates(map[string]any{"profile_id": profileID, "updated_at": time.Now().UTC()}).Error; err != nil {
		return fmt.Errorf("scope refresh token to profile: %w", err)
	}
	return nil
}

// DeleteExpired removes expired tokens older than the cutoff. It is called by a
// background maintenance task.
func (r *RefreshTokenRepository) DeleteExpired(
	ctx context.Context,
	before time.Time,
) (int64, error) {
	result := r.db.WithContext(ctx).Where("expires_at < ?", before).Delete(&domain.RefreshToken{})
	if result.Error != nil {
		return 0, fmt.Errorf("delete expired refresh tokens: %w", result.Error)
	}
	return result.RowsAffected, nil
}
