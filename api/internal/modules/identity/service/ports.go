package service

import (
	"context"
	"time"

	"github.com/pagefau1t/speedvideo/api/internal/modules/identity/domain"
)

// UserStore is the account persistence port consumed by the identity service.
type UserStore interface {
	FindByEmail(ctx context.Context, email string) (*domain.User, error)
	FindByID(ctx context.Context, id string) (*domain.User, error)
	CreateWithProfile(ctx context.Context, user *domain.User, profile *domain.Profile) error
}

// ProfileStore is the profile persistence port.
type ProfileStore interface {
	ListByUser(ctx context.Context, userID string) ([]domain.Profile, error)
	FindByIDAndUser(ctx context.Context, id, userID string) (*domain.Profile, error)
	CountByUser(ctx context.Context, userID string) (int64, error)
	Create(ctx context.Context, profile *domain.Profile) error
	Update(ctx context.Context, profile *domain.Profile) error
	Delete(ctx context.Context, profile *domain.Profile) error
}

// RefreshTokenStore is the refresh-token persistence port.
type RefreshTokenStore interface {
	Create(ctx context.Context, token *domain.RefreshToken) error
	FindByHash(ctx context.Context, hash string) (*domain.RefreshToken, error)
	Rotate(ctx context.Context, oldID string, replacement *domain.RefreshToken) error
	RevokeFamily(ctx context.Context, familyID string) error
	RevokeByProfile(ctx context.Context, profileID string) error
	Revoke(ctx context.Context, id string) error
	UpdateProfile(ctx context.Context, id, profileID string) error
	DeleteExpired(ctx context.Context, before time.Time) (int64, error)
}
