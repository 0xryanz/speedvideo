// Package adapter defines the provider protocols the collector can speak.
//
// An adapter only understands a wire format; it never decides what is legal to
// collect. Operators are responsible for the sources they register.
package adapter

import (
	"context"

	"github.com/pagefau1t/speedvideo/collector/internal/model"
)

// Episode is a playable unit exposed by a provider.
type Episode struct {
	SeasonNumber int    `json:"season_number"`
	Number       int    `json:"number"`
	Name         string `json:"name"`
	URL          string `json:"url"`
}

// Title is provider-side metadata for one movie or series.
type Title struct {
	RemoteID     string    `json:"remote_id"`
	Name         string    `json:"name"`
	OriginalName string    `json:"original_name"`
	Kind         string    `json:"kind"`
	PosterURL    string    `json:"poster_url"`
	Synopsis     string    `json:"synopsis"`
	Year         int       `json:"year"`
	Genres       []string  `json:"genres"`
	VideoURL     string    `json:"video_url"`
	Episodes     []Episode `json:"episodes"`
}

// Page is one page of provider results.
type Page struct {
	Items     []Title `json:"items"`
	Page      int     `json:"page"`
	PageCount int     `json:"page_count"`
	Total     int     `json:"total"`
}

// Category is one provider-defined content category. IDs stay strings because
// providers use both integers and slugs.
type Category struct {
	ID       string `json:"id"`
	Name     string `json:"name"`
	ParentID string `json:"parent_id,omitempty"`
	// Total is the provider-reported number of titles in this category.
	Total int `json:"total"`
}

// Adapter is implemented by each supported protocol.
type Adapter interface {
	Kind() string
	Search(ctx context.Context, src *model.Source, query string, page int) (*Page, error)
	List(ctx context.Context, src *model.Source, page int) (*Page, error)
	ListType(ctx context.Context, src *model.Source, typeID string, page int) (*Page, error)
	Categories(ctx context.Context, src *model.Source) ([]Category, error)
	Detail(ctx context.Context, src *model.Source, remoteID string) (*Title, error)
}

// Registry maps a stored adapter identifier to its implementation.
type Registry struct {
	adapters map[string]Adapter
}

// NewRegistry registers adapters by Kind.
func NewRegistry(adapters ...Adapter) *Registry {
	registry := &Registry{adapters: make(map[string]Adapter, len(adapters))}
	for _, item := range adapters {
		registry.adapters[item.Kind()] = item
	}
	return registry
}

// Get returns the adapter for a stored kind.
func (r *Registry) Get(kind string) (Adapter, bool) {
	adapter, ok := r.adapters[kind]
	return adapter, ok
}

// Kinds lists the supported adapter identifiers.
func (r *Registry) Kinds() []string {
	kinds := make([]string, 0, len(r.adapters))
	for kind := range r.adapters {
		kinds = append(kinds, kind)
	}
	return kinds
}
