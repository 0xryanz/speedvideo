package pipeline

import (
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/pagefau1t/speedvideo/collector/internal/adapter"
)

func TestHashIgnoresUnchangedTitles(t *testing.T) {
	title := &adapter.Title{
		Name: "Example", Kind: "movie", Year: 2024,
		VideoURL: "https://cdn.example/movie.m3u8",
	}
	require.Equal(t, hashOf(title), hashOf(title))

	changed := *title
	changed.VideoURL = "https://cdn.example/other.m3u8"
	require.NotEqual(t, hashOf(title), hashOf(&changed))
}

func TestHashTracksEpisodes(t *testing.T) {
	base := &adapter.Title{
		Name: "Example", Kind: "series",
		Episodes: []adapter.Episode{
			{SeasonNumber: 1, Number: 1, Name: "One", URL: "https://cdn.example/1.m3u8"},
		},
	}
	changed := *base
	changed.Episodes = append([]adapter.Episode{}, base.Episodes...)
	changed.Episodes[0].URL = "https://cdn.example/1b.m3u8"
	require.NotEqual(t, hashOf(base), hashOf(&changed))
}
