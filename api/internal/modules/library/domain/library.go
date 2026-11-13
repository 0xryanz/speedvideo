// Package domain contains the per-profile viewing state owned by the library
// module: watch lists and playback progress.
package domain

import "time"

// WatchlistEntry links a profile to a saved title.
type WatchlistEntry struct {
	ProfileID string    `gorm:"type:uuid;primaryKey" json:"profile_id"`
	TitleID   string    `gorm:"type:uuid;primaryKey" json:"title_id"`
	CreatedAt time.Time `                            json:"created_at"`
}

func (WatchlistEntry) TableName() string { return "watchlist_entries" }

// Progress is the resumable playback state for one title per profile. A series
// keeps a single row pointing at the most recently watched episode.
type Progress struct {
	ProfileID       string    `gorm:"type:uuid;primaryKey"         json:"profile_id"`
	TitleID         string    `gorm:"type:uuid;primaryKey"         json:"title_id"`
	EpisodeID       *string   `gorm:"type:uuid"                    json:"episode_id,omitempty"`
	PositionSeconds int       `gorm:"not null;default:0"           json:"position_seconds"`
	DurationSeconds int       `gorm:"not null;default:0"           json:"duration_seconds"`
	Completed       bool      `gorm:"not null;default:false;index" json:"completed"`
	UpdatedAt       time.Time `gorm:"not null"                     json:"updated_at"`
}

func (Progress) TableName() string { return "playback_progress" }
