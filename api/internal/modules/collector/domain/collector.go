// Package domain contains the collection queue entities. The API owns their
// schema and serves them to the operations console; the collector process is
// the only component that executes the jobs.
package domain

import (
	"time"

	"github.com/pagefau1t/speedvideo/api/internal/platform/model"
)

// Job kinds.
const (
	JobFull        = "full"
	JobIncremental = "incremental"
	JobTitle       = "title"
	JobPreview     = "preview"
	JobTypes       = "types"
)

// Job statuses.
const (
	JobPending = "pending"
	JobRunning = "running"
	JobDone    = "done"
	JobFailed  = "failed"
)

// Job is one queued collection task.
type Job struct {
	model.Base
	SourceID    string    `gorm:"type:uuid;not null;index" json:"source_id"`
	Kind        string    `gorm:"size:16;not null"         json:"kind"`
	RemoteID    string    `gorm:"size:120"                 json:"remote_id,omitempty"`
	Payload     string    `gorm:"type:text"                json:"-"`
	Result      string    `gorm:"type:text"                json:"-"`
	Status      string    `gorm:"size:16;not null;index"   json:"status"`
	Attempts    int       `gorm:"not null;default:0"       json:"attempts"`
	MaxAttempts int       `gorm:"not null;default:3"       json:"max_attempts"`
	RunAfter    time.Time `gorm:"not null;index"           json:"run_after"`
	LastError   string    `gorm:"size:600"                 json:"last_error,omitempty"`
	// LeaseOwner and LeaseExpiresAt let the API and collectors tell a live
	// execution apart from one interrupted by a crash or restart. The lease is
	// renewed while the job runs and expires when the process stops.
	LeaseOwner     string     `gorm:"size:120" json:"-"`
	LeaseExpiresAt *time.Time `              json:"-"`
}

// TableName keeps the collector's table name explicit.
func (Job) TableName() string { return "collect_jobs" }

// Run records one execution of a job.
type Run struct {
	model.Base
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

// TableName keeps the collector's table name explicit.
func (Run) TableName() string { return "collect_runs" }

// Item links a provider row to a local title and stores change detection state.
type Item struct {
	model.Base
	SourceID    string     `gorm:"type:uuid;not null;uniqueIndex:idx_collect_item" json:"source_id"`
	RemoteID    string     `gorm:"size:120;not null;uniqueIndex:idx_collect_item"  json:"remote_id"`
	TitleID     string     `gorm:"type:uuid;not null;index"                        json:"title_id"`
	ContentHash string     `gorm:"size:64;not null"                                json:"content_hash"`
	LastSeenAt  time.Time  `                                                       json:"last_seen_at"`
	RemovedAt   *time.Time `                                                       json:"removed_at,omitempty"`
}

// TableName keeps the collector's table name explicit.
func (Item) TableName() string { return "collect_items" }
