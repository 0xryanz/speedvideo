package service

import (
	"context"
	"testing"

	"github.com/pagefau1t/speedvideo/api/internal/modules/catalog/contracts"
	"github.com/pagefau1t/speedvideo/api/internal/modules/catalog/domain"
	"github.com/pagefau1t/speedvideo/api/internal/modules/catalog/repository"
	"github.com/stretchr/testify/require"
)

type fakeRepository struct {
	title       *domain.Title
	listLimit   int
	popular     []domain.Title
	searchQuery string
	searchKind  string
}

func (f *fakeRepository) GetByID(context.Context, string, bool) (*domain.Title, error) {
	return f.title, nil
}

func (f *fakeRepository) Featured(
	context.Context,
	bool,
) (*domain.Title, error) {
	return f.title, nil
}
func (f *fakeRepository) Popular(context.Context, bool, int) ([]domain.Title, error) {
	return f.popular, nil
}
func (f *fakeRepository) NewReleases(context.Context, bool, int) ([]domain.Title, error) {
	return f.popular, nil
}
func (f *fakeRepository) ByGenre(context.Context, string, bool, int) ([]domain.Title, error) {
	return f.popular, nil
}

func (f *fakeRepository) List(
	_ context.Context,
	filter repository.TitleFilter,
	_ bool,
) ([]domain.Title, int64, error) {
	f.listLimit = filter.PageSize
	return f.popular, 42, nil
}

func (f *fakeRepository) Search(
	_ context.Context,
	query, kind string,
	_ bool,
	_ int,
) ([]domain.Title, error) {
	f.searchQuery = query
	f.searchKind = kind
	return f.popular, nil
}

func (f *fakeRepository) Similar(
	context.Context,
	*domain.Title,
	bool,
	int,
) ([]domain.Title, error) {
	return f.popular, nil
}
func (f *fakeRepository) CardsByIDs(context.Context, []string, bool) ([]domain.Title, error) {
	return f.popular, nil
}
func (f *fakeRepository) RefreshCanonicalForSource(context.Context, string) error { return nil }
func (f *fakeRepository) Offers(context.Context, *domain.Title) ([]repository.Offer, error) {
	return []repository.Offer{
		{TitleID: "t-1", SourceID: "src-a", SourceName: "Alpha", EpisodeCount: 2},
		{TitleID: "t-2", SourceID: "src-b", SourceName: "Beta", EpisodeCount: 2},
	}, nil
}
func (f *fakeRepository) Genres(context.Context) ([]domain.Genre, error) {
	return []domain.Genre{{Slug: "drama", Name: "Drama"}}, nil
}

type fakeViewer struct {
	progress *contracts.Progress
	saved    bool
}

func (f *fakeViewer) ProgressFor(context.Context, string, string) (*contracts.Progress, error) {
	return f.progress, nil
}
func (f *fakeViewer) IsInWatchlist(context.Context, string, string) (bool, error) {
	return f.saved, nil
}

func sampleTitle() *domain.Title {
	title := &domain.Title{
		Name: "Sample", Slug: "sample", Kind: domain.KindSeries, ReleaseYear: 2024,
		MaturityRating: "TV-14", RuntimeMinutes: 50, PosterPath: "/static/posters/sample.jpg",
		BackdropPath: "/static/backdrops/sample.jpg", MatchPercent: 95, Popularity: 10,
		Genres: []domain.Genre{{Slug: "drama", Name: "Drama"}},
	}
	episodeOne := domain.Episode{
		Number:         1,
		Name:           "Pilot",
		RuntimeMinutes: 48,
		VideoURL:       "https://cdn.example/1.m3u8",
	}
	episodeOne.ID = "ep-1"
	episodeTwo := domain.Episode{
		Number:         2,
		Name:           "Second",
		RuntimeMinutes: 52,
		VideoURL:       "https://cdn.example/2.m3u8",
	}
	episodeTwo.ID = "ep-2"
	season := domain.Season{
		Number:   1,
		Name:     "Season 1",
		Episodes: []domain.Episode{episodeOne, episodeTwo},
	}
	season.ID = "season-1"
	title.Seasons = []domain.Season{season}
	return title
}

func TestDetailMergesViewerState(t *testing.T) {
	viewer := &fakeViewer{progress: contracts.NewProgress("ep-1", 120, 2880, false), saved: true}
	svc := New(&fakeRepository{title: sampleTitle()}, viewer)

	detail, err := svc.Detail(context.Background(), "title-1", "profile-1", false)

	require.NoError(t, err)
	require.Equal(t, "Sample", detail.Name)
	require.True(t, detail.InWatchlist)
	require.NotNil(t, detail.Resume)
	require.Equal(t, 4, detail.Resume.Percent)
	require.Len(t, detail.Seasons, 1)
	require.Len(t, detail.Seasons[0].Episodes, 2)
	require.Equal(t, 1, detail.Seasons[0].Episodes[1].SeasonNumber)
}

func TestPlaybackSourceSelectsEpisodeAndFallsBackToFirst(t *testing.T) {
	svc := New(&fakeRepository{title: sampleTitle()}, nil)

	source, err := svc.PlaybackSource(context.Background(), "title-1", "ep-2", false)
	require.NoError(t, err)
	require.Equal(t, "https://cdn.example/2.m3u8", source.VideoURL)
	require.Equal(t, "ep-2", source.Episode.ID)
	require.Equal(t, 52, source.Episode.RuntimeMinutes)

	source, err = svc.PlaybackSource(context.Background(), "title-1", "", false)
	require.NoError(t, err)
	require.Equal(t, "ep-1", source.Episode.ID)
}

func TestBrowseClampsPageSizeAndReportsHasMore(t *testing.T) {
	repo := &fakeRepository{popular: []domain.Title{*sampleTitle()}}
	svc := New(repo, nil)

	page, err := svc.Browse(context.Background(), BrowseFilter{Page: 1, PageSize: 500}, false)
	require.NoError(t, err)
	require.Equal(t, 50, repo.listLimit)
	require.Equal(t, 50, page.PageSize)
	require.False(t, page.HasMore)
	require.EqualValues(t, 42, page.Total)
	require.Len(t, page.Items, 1)
}

func TestSearchRequiresTwoCharacters(t *testing.T) {
	svc := New(&fakeRepository{}, nil)
	_, err := svc.Search(context.Background(), "a", "", false, 20)
	require.Error(t, err)
}

func TestSearchForwardsKindFilter(t *testing.T) {
	repo := &fakeRepository{}
	svc := New(repo, nil)

	_, err := svc.Search(context.Background(), "dune", domain.KindSeries, false, 20)
	require.NoError(t, err)
	require.Equal(t, domain.KindSeries, repo.searchKind)
}

func TestSearchRejectsUnknownKind(t *testing.T) {
	svc := New(&fakeRepository{}, nil)
	_, err := svc.Search(context.Background(), "dune", "documentary", false, 20)
	require.Error(t, err)
}

func TestDetailExposesEverySourceOffer(t *testing.T) {
	title := sampleTitle()
	title.ID = "t-1"
	svc := New(&fakeRepository{title: title}, nil)

	detail, err := svc.Detail(context.Background(), "t-1", "", false)
	require.NoError(t, err)
	require.Len(t, detail.Offers, 2)
	require.Equal(t, "Alpha", detail.Offers[0].SourceName)
	require.True(t, detail.Offers[0].Selected)
	require.False(t, detail.Offers[1].Selected)
}
