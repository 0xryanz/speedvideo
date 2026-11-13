package service

import (
	"context"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/pagefau1t/speedvideo/api/internal/modules/catalog/contracts"
	"github.com/pagefau1t/speedvideo/api/internal/modules/library/domain"
	"github.com/pagefau1t/speedvideo/api/internal/platform/apperr"
)

type fakeRepository struct {
	watchlist []string
	progress  map[string]*domain.Progress
	rows      []domain.Progress
	saved     *domain.Progress
}

func (f *fakeRepository) ListWatchlist(context.Context, string) ([]string, error) {
	return f.watchlist, nil
}
func (f *fakeRepository) AddToWatchlist(context.Context, string, string) error      { return nil }
func (f *fakeRepository) RemoveFromWatchlist(context.Context, string, string) error { return nil }
func (f *fakeRepository) IsInWatchlist(context.Context, string, string) (bool, error) {
	return false, nil
}

func (f *fakeRepository) GetProgress(
	_ context.Context,
	_, titleID string,
) (*domain.Progress, error) {
	if progress, ok := f.progress[titleID]; ok {
		return progress, nil
	}
	return nil, apperr.New(apperr.KindNotFound, "progress not found")
}
func (f *fakeRepository) UpsertProgress(_ context.Context, progress *domain.Progress) error {
	f.saved = progress
	return nil
}
func (f *fakeRepository) ContinueWatching(context.Context, string, int) ([]domain.Progress, error) {
	return f.rows, nil
}
func (f *fakeRepository) DeleteProfileState(context.Context, string) error { return nil }

type fakeTitles struct {
	cards map[string]contracts.TitleCard
}

func (f *fakeTitles) CardsByIDs(
	context.Context,
	[]string,
	bool,
) (map[string]contracts.TitleCard, error) {
	return f.cards, nil
}

func TestContinueWatchingAttachesProgressAndPreservesOrder(t *testing.T) {
	episode := "ep-1"
	repo := &fakeRepository{rows: []domain.Progress{
		{TitleID: "b", EpisodeID: &episode, PositionSeconds: 300, DurationSeconds: 1000},
		{TitleID: "a", PositionSeconds: 100, DurationSeconds: 1000},
	}}
	titles := &fakeTitles{cards: map[string]contracts.TitleCard{
		"a": {Name: "A"}, "b": {Name: "B"},
	}}
	svc := New(repo, titles)

	cards, err := svc.ContinueWatching(context.Background(), "profile", false, 10)
	require.NoError(t, err)
	require.Len(t, cards, 2)
	require.Equal(t, "B", cards[0].Name)
	require.Equal(t, 30, cards[0].Progress.Percent)
	require.Equal(t, "ep-1", cards[0].Progress.EpisodeID)
}

func TestSaveProgressClampsAndCompletes(t *testing.T) {
	repo := &fakeRepository{}
	svc := New(repo, &fakeTitles{})

	require.NoError(t, svc.SaveProgress(context.Background(), "p", "t", "", 1050, 1000))
	require.NotNil(t, repo.saved)
	require.Equal(t, 1000, repo.saved.PositionSeconds)
	require.True(t, repo.saved.Completed)
}

func TestSaveProgressRejectsOvershoot(t *testing.T) {
	svc := New(&fakeRepository{}, &fakeTitles{})
	err := svc.SaveProgress(context.Background(), "p", "t", "", 5000, 1000)
	require.Error(t, err)
}

func TestWatchlistSkipsUnknownTitles(t *testing.T) {
	repo := &fakeRepository{watchlist: []string{"known", "deleted"}}
	titles := &fakeTitles{cards: map[string]contracts.TitleCard{"known": {Name: "Known"}}}
	svc := New(repo, titles)

	cards, err := svc.Watchlist(context.Background(), "p", false)
	require.NoError(t, err)
	require.Len(t, cards, 1)
	require.Equal(t, "Known", cards[0].Name)
}

func TestProgressForReturnsNilWhenAbsent(t *testing.T) {
	svc := New(&fakeRepository{progress: map[string]*domain.Progress{}}, &fakeTitles{})
	progress, err := svc.ProgressFor(context.Background(), "p", "t")
	require.NoError(t, err)
	require.Nil(t, progress)
}
