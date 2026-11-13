// Package domain contains the persisted entities owned by the source module:
// external content providers and the rights attestation that gates them.
package domain

import (
	"time"

	"github.com/lib/pq"

	"github.com/pagefau1t/speedvideo/api/internal/platform/model"
)

// Adapter identifiers. Only documented, publicly specified wire formats are
// supported; the module ships no provider list and no discovery service.
const (
	AdapterAppleCMSV10 = "apple_cms_v10"
)

// Source is an external content provider configured by an operator.
//
// A source can only be enabled after the operator has attested that they hold
// the rights required to distribute the provider's content. The attestation is
// recorded per source so it can be audited and revoked.
type Source struct {
	model.Base
	Slug    string `gorm:"size:80;not null;uniqueIndex"           json:"slug"`
	Name    string `gorm:"size:160;not null"                      json:"name"`
	Adapter string `gorm:"size:40;not null;default:apple_cms_v10" json:"adapter"`
	APIBase string `gorm:"size:600;not null"                      json:"api_base"`
	// MediaHosts is the exhaustive set of hostnames this provider may serve
	// media from. Signed playback grants are only issued for these hosts.
	MediaHosts pq.StringArray `gorm:"type:text[]"                            json:"media_hosts"`
	Enabled    bool           `gorm:"not null;default:false;index"           json:"enabled"`

	// SelectedTypeIDs scopes collection to the provider categories the
	// operator picked. Empty means the whole catalogue.
	SelectedTypeIDs pq.StringArray `gorm:"type:text[]"        json:"selected_type_ids"`
	// Types caches the category list last discovered by the collector. The API
	// never talks to the provider, so this is the console's only offline view.
	Types string `gorm:"type:jsonb"         json:"-"`
	// FullScanPages overrides the collector's global full-scan page cap for
	// this source; 0 keeps the global default.
	FullScanPages int `gorm:"not null;default:0" json:"full_scan_pages"`

	RightsHolder      string     `gorm:"size:240"  json:"rights_holder"`
	LicenseReference  string     `gorm:"size:600"  json:"license_reference"`
	RightsConfirmedAt *time.Time `                 json:"rights_confirmed_at,omitempty"`
	RightsConfirmedBy *string    `gorm:"type:uuid" json:"rights_confirmed_by,omitempty"`

	LastSyncedAt *time.Time `json:"last_synced_at,omitempty"`
	LastSyncNote string     `json:"last_sync_note,omitempty" gorm:"size:400"`
}

// Category is one provider-defined content category (movie, series, anime…).
// IDs are opaque strings because providers use both integers and slugs.
type Category struct {
	ID       string `json:"id"`
	Name     string `json:"name"`
	ParentID string `json:"parent_id,omitempty"`
	Total    int    `json:"total"`
}

// TableName keeps the table explicit so it cannot collide with future modules.
func (Source) TableName() string { return "content_sources" }
