// Package model provides the shared persistence primitives embedded by GORM
// entities across feature modules.
package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Base is embedded by entities that use an opaque UUID primary key and
// database-managed timestamps.
type Base struct {
	ID        string    `gorm:"type:uuid;primaryKey" json:"id"`
	CreatedAt time.Time `                            json:"created_at"`
	UpdatedAt time.Time `                            json:"updated_at"`
}

// BeforeCreate assigns a UUID when the caller did not supply one.
func (b *Base) BeforeCreate(_ *gorm.DB) error {
	if b.ID == "" {
		b.ID = uuid.NewString()
	}
	return nil
}
