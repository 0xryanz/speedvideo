// Package domain contains the persisted entities owned by the identity module:
// accounts, viewing profiles and refresh-token families.
package domain

import (
	"time"

	"github.com/pagefau1t/speedvideo/api/internal/platform/model"
)

// User is a billed account. A user may own several viewing profiles.
type User struct {
	model.Base
	Email        string `gorm:"size:320;not null;uniqueIndex"     json:"email"`
	PasswordHash string `gorm:"not null"                          json:"-"`
	DisplayName  string `gorm:"size:120"                          json:"display_name"`
	Plan         string `gorm:"size:32;not null;default:standard" json:"plan"`
	Role         string `gorm:"size:32;not null;default:member"   json:"role"`
}

func (User) TableName() string { return "users" }

// Profile is a Netflix-style viewing profile. All personalised state (watch
// list, progress) is keyed by profile, never by account.
type Profile struct {
	model.Base
	UserID           string `gorm:"type:uuid;not null;index"        json:"user_id"`
	Name             string `gorm:"size:60;not null"                json:"name"`
	AvatarColor      string `gorm:"size:9;not null;default:#E50914" json:"avatar_color"`
	IsKids           bool   `gorm:"not null;default:false"          json:"is_kids"`
	Language         string `gorm:"size:8;not null;default:en"      json:"language"`
	AutoplayNext     bool   `gorm:"not null;default:true"           json:"autoplay_next"`
	AutoplayPreviews bool   `gorm:"not null;default:true"           json:"autoplay_previews"`
	MaturityRating   string `gorm:"size:16;not null;default:18+"    json:"maturity_rating"`
}

func (Profile) TableName() string { return "profiles" }

// RefreshToken is the persisted half of an opaque, rotating refresh token.
// Only the SHA-256 hash of the token is stored.
type RefreshToken struct {
	model.Base
	UserID       string     `gorm:"type:uuid;not null;index"     json:"user_id"`
	ProfileID    *string    `gorm:"type:uuid;index"              json:"profile_id,omitempty"`
	FamilyID     string     `gorm:"type:uuid;not null;index"     json:"family_id"`
	TokenHash    string     `gorm:"size:64;not null;uniqueIndex" json:"-"`
	ExpiresAt    time.Time  `gorm:"not null;index"               json:"expires_at"`
	RevokedAt    *time.Time `                                    json:"revoked_at,omitempty"`
	ReplacedByID *string    `gorm:"type:uuid"                    json:"-"`
	UserAgent    string     `gorm:"size:512"                     json:"-"`
	IPAddress    string     `gorm:"size:64"                      json:"-"`
}

func (RefreshToken) TableName() string { return "refresh_tokens" }
