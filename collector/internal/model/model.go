// Package model holds the collector's persistence structs.
//
// The API module owns the canonical schema: it creates content_sources, titles,
// seasons, episodes and genres through its own migrations. This package mirrors
// those tables so the collector can write them from a separate process. Keep the
// column definitions in sync with api/internal/modules/catalog/domain and
// api/internal/modules/source/domain.
package model

import (
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
	"gorm.io/gorm"
)

// Source is the operator-managed content provider registry. The API reads it to
// authorise playback; the collector is the only writer.
type Source struct {
	ID                string         `gorm:"type:uuid;primaryKey"                   json:"id"`
	CreatedAt         time.Time      `                                              json:"created_at"`
	UpdatedAt         time.Time      `                                              json:"updated_at"`
	Slug              string         `gorm:"size:80;not null;uniqueIndex"           json:"slug"`
	Name              string         `gorm:"size:160;not null"                      json:"name"`
	Adapter           string         `gorm:"size:40;not null;default:apple_cms_v10" json:"adapter"`
	APIBase           string         `gorm:"column:api_base;size:600;not null"      json:"api_base"`
	MediaHosts        pq.StringArray `gorm:"type:text[]"                            json:"media_hosts"`
	Enabled           bool           `gorm:"not null;default:false"                 json:"enabled"`
	SelectedTypeIDs   pq.StringArray `gorm:"type:text[]"                            json:"selected_type_ids"`
	Types             string         `gorm:"type:jsonb"                             json:"-"`
	FullScanPages     int            `gorm:"not null;default:0"                     json:"full_scan_pages"`
	RightsHolder      string         `gorm:"size:240"                               json:"rights_holder"`
	LicenseReference  string         `gorm:"size:600"                               json:"license_reference"`
	RightsConfirmedAt *time.Time     `                                              json:"rights_confirmed_at,omitempty"`
	RightsConfirmedBy *string        `gorm:"type:uuid"                              json:"rights_confirmed_by,omitempty"`
	LastSyncedAt      *time.Time     `                                              json:"last_synced_at,omitempty"`
	LastSyncNote      string         `gorm:"size:400"                               json:"last_sync_note"`
}

func (Source) TableName() string { return "content_sources" }

// Title mirrors the catalogue's titles table.
type Title struct {
	ID             string `gorm:"type:uuid;primaryKey"`
	CreatedAt      time.Time
	UpdatedAt      time.Time
	Slug           string `gorm:"size:160;not null"`
	Name           string `gorm:"size:240;not null"`
	OriginalName   string `gorm:"size:240"`
	Kind           string `gorm:"size:16;not null"`
	Synopsis       string `gorm:"type:text"`
	Tagline        string `gorm:"size:300"`
	ReleaseYear    int
	MaturityRating string `gorm:"size:16;not null"`
	RuntimeMinutes int
	PosterPath     string         `gorm:"size:300"`
	BackdropPath   string         `gorm:"size:300"`
	LogoPath       string         `gorm:"size:300"`
	TrailerURL     string         `gorm:"size:600"`
	VideoURL       string         `gorm:"size:1000;not null"`
	DownloadURL    string         `gorm:"size:1000"`
	Director       string         `gorm:"size:240"`
	Country        string         `gorm:"size:120"`
	Cast           pq.StringArray `gorm:"type:text[]"`
	Badges         pq.StringArray `gorm:"type:text[]"`
	Featured       bool
	Popularity     float64
	MatchPercent   int
	SourceID       *string `gorm:"type:uuid"`
	RemoteID       string  `gorm:"size:120"`
	RemovedAt      *time.Time
	// WorkKey groups identical works offered by several sources; Canonical
	// marks the single row that feeds browse and search.
	WorkKey   string `gorm:"size:240;index"`
	Canonical bool   `gorm:"not null;default:true"`
	// Genres is only used to maintain the title_genres join table; it is never
	// preloaded by the collector.
	Genres []Genre `gorm:"many2many:title_genres"`
}

func (Title) TableName() string { return "titles" }

// Season mirrors the catalogue's seasons table.
type Season struct {
	ID        string `gorm:"type:uuid;primaryKey"`
	CreatedAt time.Time
	UpdatedAt time.Time
	TitleID   string `gorm:"type:uuid;not null"`
	Number    int
	Name      string `gorm:"size:160"`
}

func (Season) TableName() string { return "seasons" }

// Episode mirrors the catalogue's episodes table.
type Episode struct {
	ID             string `gorm:"type:uuid;primaryKey"`
	CreatedAt      time.Time
	UpdatedAt      time.Time
	SeasonID       string `gorm:"type:uuid;not null"`
	Number         int
	Name           string `gorm:"size:240;not null"`
	Synopsis       string `gorm:"type:text"`
	RuntimeMinutes int
	StillPath      string `gorm:"size:300"`
	VideoURL       string `gorm:"size:1000;not null"`
	DownloadURL    string `gorm:"size:1000"`
}

func (Episode) TableName() string { return "episodes" }

// Genre mirrors the catalogue's genres table.
type Genre struct {
	ID        string `gorm:"type:uuid;primaryKey"`
	CreatedAt time.Time
	UpdatedAt time.Time
	Slug      string `gorm:"size:80;not null"`
	Name      string `gorm:"size:80;not null"`
}

func (Genre) TableName() string { return "genres" }

// BeforeCreate assigns the UUID the API's schema expects. The API creates the
// table; the collector still inserts rows, so it must supply their keys.
func (g *Genre) BeforeCreate(_ *gorm.DB) error {
	if g.ID == "" {
		g.ID = uuid.NewString()
	}
	return nil
}

// Job is one queued collection task.
type Job struct {
	ID        string    `gorm:"type:uuid;primaryKey"     json:"id"`
	CreatedAt time.Time `                                json:"created_at"`
	UpdatedAt time.Time `                                json:"updated_at"`
	SourceID  string    `gorm:"type:uuid;not null;index" json:"source_id"`
	Kind      string    `gorm:"size:16;not null"         json:"kind"` // full | incremental | title
	RemoteID  string    `gorm:"size:120"                 json:"remote_id,omitempty"`
	// Payload carries preview options; Result carries the preview snapshot.
	// Both are opaque JSON owned by the collector.
	Payload     string    `gorm:"type:text"                json:"-"`
	Result      string    `gorm:"type:text"                json:"-"`
	Status      string    `gorm:"size:16;not null;index"   json:"status"` // pending | running | done | failed
	Attempts    int       `gorm:"not null;default:0"       json:"attempts"`
	MaxAttempts int       `gorm:"not null;default:3"       json:"max_attempts"`
	RunAfter    time.Time `gorm:"not null;index"           json:"run_after"`
	LastError   string    `gorm:"size:600"                 json:"last_error,omitempty"`
	// LeaseOwner and LeaseExpiresAt mark a live execution. A running job whose
	// lease expired was interrupted by a crash or restart and is claimable
	// again instead of being stranded.
	LeaseOwner     string     `gorm:"size:120" json:"-"`
	LeaseExpiresAt *time.Time `              json:"-"`
}

func (Job) TableName() string { return "collect_jobs" }

// Run records one execution of a job.
type Run struct {
	ID         string     `gorm:"type:uuid;primaryKey"     json:"id"`
	CreatedAt  time.Time  `                                json:"created_at"`
	JobID      string     `gorm:"type:uuid;not null;index" json:"job_id"`
	SourceID   string     `gorm:"type:uuid;not null;index" json:"source_id"`
	Kind       string     `gorm:"size:16;not null"         json:"kind"`
	StartedAt  time.Time  `                                json:"started_at"`
	FinishedAt *time.Time `                                json:"finished_at,omitempty"`
	Fetched    int        `                                json:"fetched"`
	Created    int        `                                json:"created"`
	Updated    int        `                                json:"updated"`
	Skipped    int        `                                json:"skipped"`
	Failed     int        `                                json:"failed"`
	Error      string     `gorm:"size:1000"                json:"error,omitempty"`
}

func (Run) TableName() string { return "collect_runs" }

// Item links a provider row to a local title and stores change detection state.
type Item struct {
	ID          string     `gorm:"type:uuid;primaryKey"                            json:"id"`
	CreatedAt   time.Time  `                                                       json:"created_at"`
	UpdatedAt   time.Time  `                                                       json:"updated_at"`
	SourceID    string     `gorm:"type:uuid;not null;uniqueIndex:idx_collect_item" json:"source_id"`
	RemoteID    string     `gorm:"size:120;not null;uniqueIndex:idx_collect_item"  json:"remote_id"`
	TitleID     string     `gorm:"type:uuid;not null;index"                        json:"title_id"`
	ContentHash string     `gorm:"size:64;not null"                                json:"content_hash"`
	LastSeenAt  time.Time  `                                                       json:"last_seen_at"`
	RemovedAt   *time.Time `                                                       json:"removed_at,omitempty"`
}

func (Item) TableName() string { return "collect_items" }
