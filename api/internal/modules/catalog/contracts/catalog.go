// Package contracts defines the public, transport-facing read models of the
// catalog module. Other feature modules (library, home, playback) depend on
// these types instead of catalog's persistence entities.
package contracts

// Genre is a catalogue category exposed to clients.
type Genre struct {
	Slug string `json:"slug"`
	Name string `json:"name"`
}

// Progress is a viewer's resumable position for a title.
type Progress struct {
	EpisodeID       string `json:"episode_id,omitempty"`
	PositionSeconds int    `json:"position_seconds"`
	DurationSeconds int    `json:"duration_seconds"`
	Percent         int    `json:"percent"`
	Completed       bool   `json:"completed"`
}

// NewProgress builds a progress value and clamps the percentage to 0-100.
func NewProgress(episodeID string, positionSeconds, durationSeconds int, completed bool) *Progress {
	percent := 0
	if durationSeconds > 0 {
		percent = positionSeconds * 100 / durationSeconds
	}
	if percent < 0 {
		percent = 0
	}
	if percent > 100 {
		percent = 100
	}
	return &Progress{
		EpisodeID:       episodeID,
		PositionSeconds: positionSeconds,
		DurationSeconds: durationSeconds,
		Percent:         percent,
		Completed:       completed,
	}
}

// TitleCard is the compact representation used by rows, grids and search.
type TitleCard struct {
	ID             string    `json:"id"`
	Slug           string    `json:"slug"`
	Name           string    `json:"name"`
	Kind           string    `json:"kind"`
	ReleaseYear    int       `json:"release_year"`
	MaturityRating string    `json:"maturity_rating"`
	RuntimeMinutes int       `json:"runtime_minutes"`
	PosterPath     string    `json:"poster_path"`
	BackdropPath   string    `json:"backdrop_path"`
	LogoPath       string    `json:"logo_path,omitempty"`
	MatchPercent   int       `json:"match_percent"`
	Badges         []string  `json:"badges"`
	Genres         []Genre   `json:"genres"`
	Progress       *Progress `json:"progress,omitempty"`
}

// Episode is a playable series episode.
type Episode struct {
	ID             string `json:"id"`
	Number         int    `json:"number"`
	SeasonNumber   int    `json:"season_number"`
	Name           string `json:"name"`
	Synopsis       string `json:"synopsis"`
	RuntimeMinutes int    `json:"runtime_minutes"`
	StillPath      string `json:"still_path"`
}

// Season groups episodes for a series.
type Season struct {
	ID       string    `json:"id"`
	Number   int       `json:"number"`
	Name     string    `json:"name"`
	Episodes []Episode `json:"episodes"`
}

// TitleOffer is one playable rendition of a work. A film licensed from several
// providers exposes one offer per provider; clients let the viewer choose.
type TitleOffer struct {
	TitleID      string `json:"title_id"`
	SourceID     string `json:"source_id,omitempty"`
	SourceName   string `json:"source_name"`
	EpisodeCount int    `json:"episode_count"`
	Selected     bool   `json:"selected"`
}

// TitleDetail is the full title page payload.
type TitleDetail struct {
	TitleCard
	OriginalName string       `json:"original_name"`
	Synopsis     string       `json:"synopsis"`
	Tagline      string       `json:"tagline"`
	Director     string       `json:"director"`
	Country      string       `json:"country"`
	Cast         []string     `json:"cast"`
	TrailerURL   string       `json:"trailer_url"`
	InWatchlist  bool         `json:"in_watchlist"`
	Resume       *Progress    `json:"resume,omitempty"`
	Seasons      []Season     `json:"seasons,omitempty"`
	Offers       []TitleOffer `json:"offers"`
}

// EpisodeRef identifies the episode a playback session belongs to.
type EpisodeRef struct {
	ID             string `json:"id"`
	Number         int    `json:"number"`
	SeasonNumber   int    `json:"season_number"`
	Name           string `json:"name"`
	RuntimeMinutes int    `json:"runtime_minutes"`
}

// DownloadSource is the entitled offline rendition resolved by the catalog.
// Like PlaybackSource it is never exposed directly: the download module signs
// a short-lived grant around it.
type DownloadSource struct {
	TitleID        string      `json:"-"`
	TitleName      string      `json:"-"`
	FileName       string      `json:"-"`
	FileURL        string      `json:"-"`
	RuntimeSeconds int         `json:"-"`
	PosterPath     string      `json:"-"`
	BackdropPath   string      `json:"-"`
	Episode        *EpisodeRef `json:"-"`
}

// PlaybackSource is the entitled playable resource resolved by the catalog.
// The URL is never exposed directly to clients; playback signs it.
type PlaybackSource struct {
	TitleID        string      `json:"-"`
	TitleName      string      `json:"-"`
	VideoURL       string      `json:"-"`
	SourceID       string      `json:"-"`
	RuntimeSeconds int         `json:"-"`
	PosterPath     string      `json:"-"`
	BackdropPath   string      `json:"-"`
	Episode        *EpisodeRef `json:"-"`
}
