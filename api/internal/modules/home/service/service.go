// Package service composes the personalised home feed from catalog and library
// capabilities. It owns no persistence and has no knowledge of HTTP.
package service

import (
	"context"
	"fmt"

	"github.com/pagefau1t/speedvideo/api/internal/modules/catalog/contracts"
	"github.com/pagefau1t/speedvideo/api/internal/platform/apperr"
)

// CatalogReader is the catalog capability required by the home feed.
type CatalogReader interface {
	Featured(ctx context.Context, kids bool) (*contracts.TitleCard, error)
	Popular(ctx context.Context, kids bool, limit int) ([]contracts.TitleCard, error)
	NewReleases(ctx context.Context, kids bool, limit int) ([]contracts.TitleCard, error)
	ByGenre(
		ctx context.Context,
		genreSlug string,
		kids bool,
		limit int,
	) ([]contracts.TitleCard, error)
	Genres(ctx context.Context) ([]contracts.Genre, error)
}

// LibraryReader is the per-profile library capability required by the feed.
type LibraryReader interface {
	ContinueWatching(
		ctx context.Context,
		profileID string,
		kids bool,
		limit int,
	) ([]contracts.TitleCard, error)
	Watchlist(ctx context.Context, profileID string, kids bool) ([]contracts.TitleCard, error)
}

// Row is one horizontally scrollable shelf.
type Row struct {
	ID     string                `json:"id"`
	Title  string                `json:"title"`
	Kind   string                `json:"kind"`
	Ranked bool                  `json:"ranked"`
	Items  []contracts.TitleCard `json:"items"`
}

// Feed is the home screen payload.
type Feed struct {
	Billboard *contracts.TitleCard `json:"billboard"`
	Rows      []Row                `json:"rows"`
}

// Service composes home feeds.
type Service struct {
	catalog CatalogReader
	library LibraryReader
}

// New builds the home-feed service.
func New(catalog CatalogReader, library LibraryReader) *Service {
	return &Service{catalog: catalog, library: library}
}

var featuredGenres = []string{
	"sci-fi",
	"thriller",
	"drama",
	"crime",
	"comedy",
	"animation",
	"fantasy",
}

// Build returns the feed for a profile.
func (s *Service) Build(ctx context.Context, profileID string, kids bool) (*Feed, error) {
	billboard, err := s.catalog.Featured(ctx, kids)
	if err != nil && !apperr.IsKind(err, apperr.KindNotFound) {
		return nil, fmt.Errorf("load billboard: %w", err)
	}
	// An empty catalogue is a valid state: the instance has not collected any
	// titles yet, so the feed is served with no billboard and no rows.
	feed := &Feed{Billboard: billboard, Rows: make([]Row, 0, 8)}

	if profileID != "" {
		continueWatching, err := s.library.ContinueWatching(ctx, profileID, kids, 12)
		if err != nil {
			return nil, fmt.Errorf("load continue watching: %w", err)
		}
		if len(continueWatching) > 0 {
			feed.Rows = append(feed.Rows, Row{
				ID: "continue-watching", Title: "Continue Watching", Kind: "continue",
				Items: continueWatching,
			})
		}
	}

	popular, err := s.catalog.Popular(ctx, kids, 10)
	if err != nil {
		return nil, fmt.Errorf("load popular: %w", err)
	}
	if len(popular) > 0 {
		feed.Rows = append(feed.Rows, Row{
			ID: "top-10", Title: "Top 10 in Your Country Today", Kind: "ranked", Ranked: true,
			Items: popular,
		})
	}

	releases, err := s.catalog.NewReleases(ctx, kids, 18)
	if err != nil {
		return nil, fmt.Errorf("load new releases: %w", err)
	}
	if len(releases) > 0 {
		feed.Rows = append(feed.Rows, Row{
			ID: "new-releases", Title: "New Releases", Kind: "standard", Items: releases,
		})
	}

	if profileID != "" {
		watchlist, err := s.library.Watchlist(ctx, profileID, kids)
		if err != nil {
			return nil, fmt.Errorf("load watchlist: %w", err)
		}
		if len(watchlist) > 0 {
			feed.Rows = append(feed.Rows, Row{
				ID: "my-list", Title: "My List", Kind: "standard", Items: watchlist,
			})
		}
	}

	genres, err := s.catalog.Genres(ctx)
	if err != nil {
		return nil, fmt.Errorf("load genres: %w", err)
	}
	names := make(map[string]string, len(genres))
	for _, genre := range genres {
		names[genre.Slug] = genre.Name
	}
	for _, slug := range featuredGenres {
		name, ok := names[slug]
		if !ok {
			continue
		}
		cards, err := s.catalog.ByGenre(ctx, slug, kids, 18)
		if err != nil {
			return nil, fmt.Errorf("load genre %s: %w", slug, err)
		}
		if len(cards) < 2 {
			continue
		}
		feed.Rows = append(feed.Rows, Row{
			ID: "genre-" + slug, Title: name, Kind: "standard", Items: cards,
		})
		if len(feed.Rows) >= 8 {
			break
		}
	}
	return feed, nil
}
