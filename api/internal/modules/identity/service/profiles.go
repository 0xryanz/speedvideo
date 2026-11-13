package service

import (
	"context"
	"fmt"
	"regexp"
	"strings"

	"github.com/pagefau1t/speedvideo/api/internal/modules/identity/domain"
	"github.com/pagefau1t/speedvideo/api/internal/platform/apperr"
)

var colorPattern = regexp.MustCompile(`^#[0-9a-fA-F]{6}$`)

// CreateProfileInput describes a new viewing profile.
type CreateProfileInput struct {
	Name        string
	IsKids      bool
	AvatarColor string
	Language    string
}

// UpdateProfileInput holds optional profile changes.
type UpdateProfileInput struct {
	Name        *string
	IsKids      *bool
	AvatarColor *string
	Language    *string
}

// ProfileService owns the profile lifecycle and enforces plan limits.
type ProfileService struct {
	profiles    ProfileStore
	refresh     RefreshTokenStore
	maxProfiles int
}

// NewProfileService builds the profile use-case service.
func NewProfileService(
	profiles ProfileStore,
	refresh RefreshTokenStore,
	maxProfiles int,
) *ProfileService {
	if maxProfiles < 1 {
		maxProfiles = 5
	}
	return &ProfileService{profiles: profiles, refresh: refresh, maxProfiles: maxProfiles}
}

// List returns every profile owned by an account.
func (s *ProfileService) List(ctx context.Context, userID string) ([]domain.Profile, error) {
	return s.profiles.ListByUser(ctx, userID)
}

// Create adds a profile while respecting the plan's profile limit.
func (s *ProfileService) Create(
	ctx context.Context,
	userID string,
	input CreateProfileInput,
) (*domain.Profile, error) {
	name := strings.TrimSpace(input.Name)
	if name == "" {
		return nil, apperr.New(apperr.KindValidation, "profile name is required")
	}
	if len([]rune(name)) > 30 {
		return nil, apperr.New(apperr.KindValidation, "profile name must be at most 30 characters")
	}
	count, err := s.profiles.CountByUser(ctx, userID)
	if err != nil {
		return nil, err
	}
	if count >= int64(s.maxProfiles) {
		return nil, apperr.New(apperr.KindConflict, "profile limit reached")
	}
	color := strings.TrimSpace(input.AvatarColor)
	if color == "" {
		color = "#E50914"
	}
	if !colorPattern.MatchString(color) {
		return nil, apperr.New(
			apperr.KindValidation,
			"avatar_color must be a hex colour such as #E50914",
		)
	}
	language := input.Language
	if language != "zh" {
		language = "en"
	}
	profile := &domain.Profile{
		UserID:           userID,
		Name:             name,
		AvatarColor:      strings.ToUpper(color),
		IsKids:           input.IsKids,
		Language:         language,
		AutoplayNext:     true,
		AutoplayPreviews: true,
		MaturityRating:   maturityFor(input.IsKids),
	}
	if err := s.profiles.Create(ctx, profile); err != nil {
		return nil, err
	}
	return profile, nil
}

// Update applies partial profile changes.
func (s *ProfileService) Update(
	ctx context.Context,
	userID, profileID string,
	input UpdateProfileInput,
) (*domain.Profile, error) {
	profile, err := s.profiles.FindByIDAndUser(ctx, profileID, userID)
	if err != nil {
		return nil, err
	}
	if input.Name != nil {
		name := strings.TrimSpace(*input.Name)
		if name == "" {
			return nil, apperr.New(apperr.KindValidation, "profile name is required")
		}
		if len([]rune(name)) > 30 {
			return nil, apperr.New(
				apperr.KindValidation,
				"profile name must be at most 30 characters",
			)
		}
		profile.Name = name
	}
	if input.AvatarColor != nil {
		if !colorPattern.MatchString(*input.AvatarColor) {
			return nil, apperr.New(
				apperr.KindValidation,
				"avatar_color must be a hex colour such as #E50914",
			)
		}
		profile.AvatarColor = strings.ToUpper(*input.AvatarColor)
	}
	if input.Language != nil {
		if *input.Language != "en" && *input.Language != "zh" {
			return nil, apperr.New(apperr.KindValidation, "language must be en or zh")
		}
		profile.Language = *input.Language
	}
	if input.IsKids != nil {
		profile.IsKids = *input.IsKids
		profile.MaturityRating = maturityFor(profile.IsKids)
	}
	if err := s.profiles.Update(ctx, profile); err != nil {
		return nil, err
	}
	return profile, nil
}

// Delete removes a profile and revokes its sessions. The last profile cannot be
// deleted.
func (s *ProfileService) Delete(ctx context.Context, userID, profileID string) error {
	profile, err := s.profiles.FindByIDAndUser(ctx, profileID, userID)
	if err != nil {
		return err
	}
	count, err := s.profiles.CountByUser(ctx, userID)
	if err != nil {
		return err
	}
	if count <= 1 {
		return apperr.New(apperr.KindConflict, "at least one profile is required")
	}
	if err := s.refresh.RevokeByProfile(ctx, profile.ID); err != nil {
		return fmt.Errorf("revoke profile sessions: %w", err)
	}
	return s.profiles.Delete(ctx, profile)
}

func maturityFor(isKids bool) string {
	if isKids {
		return "7+"
	}
	return "18+"
}
