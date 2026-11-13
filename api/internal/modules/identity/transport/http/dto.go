package httpapi

import (
	"time"

	"github.com/pagefau1t/speedvideo/api/internal/modules/identity/domain"
	"github.com/pagefau1t/speedvideo/api/internal/modules/identity/service"
)

type registerRequest struct {
	Email       string `json:"email"        validate:"required,email,max=320"`
	Password    string `json:"password"     validate:"required,min=8,max=128"`
	DisplayName string `json:"display_name" validate:"max=120"`
}

type loginRequest struct {
	Email    string `json:"email"    validate:"required,email,max=320"`
	Password string `json:"password" validate:"required,min=1,max=128"`
}

type refreshRequest struct {
	RefreshToken string `json:"refresh_token" validate:"required"`
}

type selectProfileRequest struct {
	RefreshToken string `json:"refresh_token" validate:"required"`
}

type createProfileRequest struct {
	Name        string `json:"name"         validate:"required,max=30"`
	IsKids      bool   `json:"is_kids"`
	AvatarColor string `json:"avatar_color" validate:"omitempty,max=9"`
	Language    string `json:"language"     validate:"omitempty,oneof=en zh"`
}

type updateProfileRequest struct {
	Name        *string `json:"name"         validate:"omitempty,max=30"`
	IsKids      *bool   `json:"is_kids"`
	AvatarColor *string `json:"avatar_color" validate:"omitempty,max=9"`
	Language    *string `json:"language"     validate:"omitempty,oneof=en zh"`
}

type userResponse struct {
	ID          string    `json:"id"`
	Email       string    `json:"email"`
	DisplayName string    `json:"display_name"`
	Plan        string    `json:"plan"`
	Role        string    `json:"role"`
	CreatedAt   time.Time `json:"created_at"`
}

type profileResponse struct {
	ID               string    `json:"id"`
	Name             string    `json:"name"`
	AvatarColor      string    `json:"avatar_color"`
	IsKids           bool      `json:"is_kids"`
	Language         string    `json:"language"`
	AutoplayNext     bool      `json:"autoplay_next"`
	AutoplayPreviews bool      `json:"autoplay_previews"`
	MaturityRating   string    `json:"maturity_rating"`
	CreatedAt        time.Time `json:"created_at"`
}

type sessionResponse struct {
	AccessToken     string            `json:"access_token"`
	RefreshToken    string            `json:"refresh_token"`
	TokenType       string            `json:"token_type"`
	ExpiresIn       int               `json:"expires_in"`
	ExpiresAt       time.Time         `json:"expires_at"`
	User            userResponse      `json:"user"`
	Profiles        []profileResponse `json:"profiles"`
	ActiveProfileID string            `json:"active_profile_id,omitempty"`
}

type meResponse struct {
	User            userResponse      `json:"user"`
	Profiles        []profileResponse `json:"profiles"`
	ActiveProfileID string            `json:"active_profile_id,omitempty"`
}

func toUser(user *domain.User) userResponse {
	return userResponse{
		ID:          user.ID,
		Email:       user.Email,
		DisplayName: user.DisplayName,
		Plan:        user.Plan,
		Role:        user.Role,
		CreatedAt:   user.CreatedAt,
	}
}

func toProfile(profile domain.Profile) profileResponse {
	return profileResponse{
		ID:               profile.ID,
		Name:             profile.Name,
		AvatarColor:      profile.AvatarColor,
		IsKids:           profile.IsKids,
		Language:         profile.Language,
		AutoplayNext:     profile.AutoplayNext,
		AutoplayPreviews: profile.AutoplayPreviews,
		MaturityRating:   profile.MaturityRating,
		CreatedAt:        profile.CreatedAt,
	}
}

func toProfiles(profiles []domain.Profile) []profileResponse {
	out := make([]profileResponse, 0, len(profiles))
	for _, profile := range profiles {
		out = append(out, toProfile(profile))
	}
	return out
}

func toSession(session *service.Session) sessionResponse {
	expiresIn := int(time.Until(session.ExpiresAt).Seconds())
	if expiresIn < 0 {
		expiresIn = 0
	}
	return sessionResponse{
		AccessToken:     session.AccessToken,
		RefreshToken:    session.RefreshToken,
		TokenType:       "Bearer",
		ExpiresIn:       expiresIn,
		ExpiresAt:       session.ExpiresAt,
		User:            toUser(session.User),
		Profiles:        toProfiles(session.Profiles),
		ActiveProfileID: session.ActiveProfileID,
	}
}
