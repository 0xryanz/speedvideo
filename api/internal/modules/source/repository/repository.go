// Package repository implements source persistence with GORM.
package repository

import (
	"context"
	"errors"
	"fmt"

	"gorm.io/gorm"

	"github.com/pagefau1t/speedvideo/api/internal/modules/source/domain"
	"github.com/pagefau1t/speedvideo/api/internal/platform/apperr"
)

// Repository is the source persistence gateway.
type Repository struct {
	db *gorm.DB
}

// New builds a source repository.
func New(db *gorm.DB) *Repository {
	return &Repository{db: db}
}

// List returns every configured provider, enabled first.
func (r *Repository) List(ctx context.Context) ([]domain.Source, error) {
	var sources []domain.Source
	if err := r.db.WithContext(ctx).
		Order("enabled DESC, name ASC").
		Find(&sources).Error; err != nil {
		return nil, fmt.Errorf("list content sources: %w", err)
	}
	return sources, nil
}

// FindByID loads a provider by id.
func (r *Repository) FindByID(ctx context.Context, id string) (*domain.Source, error) {
	var source domain.Source
	if err := r.db.WithContext(ctx).Where("id = ?", id).First(&source).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, apperr.New(apperr.KindNotFound, "content source not found")
		}
		return nil, fmt.Errorf("load content source: %w", err)
	}
	return &source, nil
}

// FindBySlug loads a provider by slug.
func (r *Repository) FindBySlug(ctx context.Context, slug string) (*domain.Source, error) {
	var source domain.Source
	if err := r.db.WithContext(ctx).Where("slug = ?", slug).First(&source).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, apperr.New(apperr.KindNotFound, "content source not found")
		}
		return nil, fmt.Errorf("load content source: %w", err)
	}
	return &source, nil
}

// Create persists a new provider.
func (r *Repository) Create(ctx context.Context, source *domain.Source) error {
	if err := r.db.WithContext(ctx).Create(source).Error; err != nil {
		return fmt.Errorf("create content source: %w", err)
	}
	return nil
}

// Update persists operator changes to a provider.
func (r *Repository) Update(ctx context.Context, source *domain.Source) error {
	if err := r.db.WithContext(ctx).Save(source).Error; err != nil {
		return fmt.Errorf("update content source: %w", err)
	}
	return nil
}

// Delete removes a provider. Collected titles are hidden because the catalogue
// only exposes content from enabled sources, and playback re-checks the source
// on every grant redemption.
func (r *Repository) Delete(ctx context.Context, id string) error {
	if err := r.db.WithContext(ctx).Delete(&domain.Source{}, "id = ?", id).Error; err != nil {
		return fmt.Errorf("delete content source: %w", err)
	}
	return nil
}

// MediaHosts implements media.SourceHosts. Disabled or missing sources resolve
// to an error, which revokes every outstanding media grant for their content.
func (r *Repository) MediaHosts(ctx context.Context, sourceID string) ([]string, error) {
	source, err := r.FindByID(ctx, sourceID)
	if err != nil {
		return nil, err
	}
	if !source.Enabled {
		return nil, apperr.New(apperr.KindForbidden, "content source is disabled")
	}
	return source.MediaHosts, nil
}
