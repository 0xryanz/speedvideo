// Package domain contains the catalog entities. The module owns titles,
// genres, seasons and episodes; other modules depend on its contracts, never
// on these GORM structures.
package domain

import (
	"time"

	"github.com/lib/pq"

	"github.com/pagefau1t/speedvideo/api/internal/platform/model"
)

// Title kinds supported by the catalogue.
const (
	KindMovie  = "movie"
	KindSeries = "series"
)

// KidsSafeRatings is the allow-list applied to kids profiles. Everything else
// is hard-filtered before it can reach the API.
var KidsSafeRatings = []string{"G", "PG", "TV-Y", "TV-Y7", "TV-G", "TV-PG", "ALL", "7+"}

// Genre is a browsable catalogue category.
type Genre struct {
	model.Base
	Slug string `gorm:"size:80;not null;uniqueIndex" json:"slug"`
	Name string `gorm:"size:80;not null"             json:"name"`
}

func (Genre) TableName() string { return "genres" }

// Title is a movie or a series.
type Title struct {
	model.Base
	Slug           string `gorm:"size:160;not null;uniqueIndex"                                  json:"slug"`
	Name           string `gorm:"size:240;not null;index"                                        json:"name"`
	OriginalName   string `gorm:"size:240"                                                       json:"original_name"`
	Kind           string `gorm:"size:16;not null;index"                                         json:"kind"`
	Synopsis       string `gorm:"type:text"                                                      json:"synopsis"`
	Tagline        string `gorm:"size:300"                                                       json:"tagline"`
	ReleaseYear    int    `gorm:"not null;index"                                                 json:"release_year"`
	MaturityRating string `gorm:"size:16;not null;index"                                         json:"maturity_rating"`
	RuntimeMinutes int    `                                                                      json:"runtime_minutes"`
	PosterPath     string `gorm:"size:300"                                                       json:"poster_path"`
	BackdropPath   string `gorm:"size:300"                                                       json:"backdrop_path"`
	LogoPath       string `gorm:"size:300"                                                       json:"logo_path"`
	TrailerURL     string `gorm:"size:600"                                                       json:"trailer_url"`
	VideoURL       string `gorm:"size:1000;not null"                                             json:"-"`
	DownloadURL    string `gorm:"size:1000"                                                      json:"-"`
	// SourceID/RemoteID link a title to the external content provider it was
	// imported from. NULL for locally hosted titles.
	SourceID *string `gorm:"type:uuid;index;uniqueIndex:idx_title_source_remote,priority:1" json:"source_id,omitempty"`
	RemoteID string  `gorm:"size:120;index;uniqueIndex:idx_title_source_remote,priority:2"  json:"remote_id,omitempty"`
	// RemovedAt hides a title whose upstream rendition disappeared. The row is
	// kept so watchlists and progress survive; a later re-collect clears it.
	RemovedAt *time.Time `gorm:"index"                                                          json:"-"`
	// WorkKey groups the same title offered by several content sources. Each
	// source keeps its own row (its own renditions); exactly one row per key is
	// canonical and drives browse, search and the home feed, while the detail
	// page lists every offer so the viewer can pick a source. Empty means the
	// title is ungrouped and always treated as canonical.
	WorkKey      string         `gorm:"size:240;index"                                                 json:"-"`
	Canonical    bool           `gorm:"not null;default:true"                                          json:"-"`
	Director     string         `gorm:"size:240"                                                       json:"director"`
	Country      string         `gorm:"size:120"                                                       json:"country"`
	Cast         pq.StringArray `gorm:"type:text[]"                                                    json:"cast"`
	Badges       pq.StringArray `gorm:"type:text[]"                                                    json:"badges"`
	Featured     bool           `gorm:"not null;default:false;index"                                   json:"featured"`
	Popularity   float64        `gorm:"not null;default:0;index"                                       json:"popularity"`
	MatchPercent int            `gorm:"not null;default:90"                                            json:"match_percent"`
	Genres       []Genre        `gorm:"many2many:title_genres"                                         json:"genres"`
	Seasons      []Season       `gorm:"constraint:OnDelete:CASCADE"                                    json:"seasons,omitempty"`
}

func (Title) TableName() string { return "titles" }

// Season groups episodes for a series.
type Season struct {
	model.Base
	TitleID  string    `gorm:"type:uuid;not null;index"    json:"-"`
	Number   int       `gorm:"not null"                    json:"number"`
	Name     string    `gorm:"size:160"                    json:"name"`
	Episodes []Episode `gorm:"constraint:OnDelete:CASCADE" json:"episodes,omitempty"`
}

func (Season) TableName() string { return "seasons" }

// Episode is a playable unit of a series.
type Episode struct {
	model.Base
	SeasonID       string `gorm:"type:uuid;not null;index" json:"-"`
	Number         int    `gorm:"not null"                 json:"number"`
	Name           string `gorm:"size:240;not null"        json:"name"`
	Synopsis       string `gorm:"type:text"                json:"synopsis"`
	RuntimeMinutes int    `                                json:"runtime_minutes"`
	StillPath      string `gorm:"size:300"                 json:"still_path"`
	VideoURL       string `gorm:"size:1000;not null"       json:"-"`
	DownloadURL    string `gorm:"size:1000"                json:"-"`
}

func (Episode) TableName() string { return "episodes" }
