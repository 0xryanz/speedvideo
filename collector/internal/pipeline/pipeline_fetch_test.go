package pipeline

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strconv"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/pagefau1t/speedvideo/collector/internal/adapter"
	"github.com/pagefau1t/speedvideo/collector/internal/model"
)

func TestFetchTypePagesFetchesPagesInParallel(t *testing.T) {
	var (
		mu        sync.Mutex
		requested = map[int]int{}
		active    atomic.Int32
		peak      atomic.Int32
	)
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		page, _ := strconv.Atoi(r.URL.Query().Get("pg"))
		mu.Lock()
		requested[page]++
		mu.Unlock()

		current := active.Add(1)
		for {
			previous := peak.Load()
			if current <= previous || peak.CompareAndSwap(previous, current) {
				break
			}
		}
		defer active.Add(-1)
		time.Sleep(30 * time.Millisecond)

		_ = json.NewEncoder(w).Encode(map[string]any{
			"code":      1,
			"page":      page,
			"pagecount": 5,
			"total":     25,
			"list": []map[string]any{{
				"vod_id":   page,
				"vod_name": fmt.Sprintf("Title %d", page),
				"vod_pic":  "https://img.example/poster.jpg",
			}},
		})
	}))
	defer server.Close()

	p := New(nil, adapter.NewRegistry(adapter.NewAppleCMS()), true, 0, 3, time.Hour, 8, 4)
	source := &model.Source{APIBase: server.URL}
	pages, err := p.fetchTypePages(context.Background(), source, adapter.NewAppleCMS(), "1", 0)
	require.NoError(t, err)
	require.Len(t, pages, 5)
	for index, page := range pages {
		require.Equal(t, index+1, page.Page)
	}

	mu.Lock()
	defer mu.Unlock()
	for page := 1; page <= 5; page++ {
		require.Equal(t, 1, requested[page], "page %d requested once", page)
	}
	require.Greater(t, peak.Load(), int32(1), "pages should overlap")
	require.LessOrEqual(t, peak.Load(), int32(4))
}

func TestFetchTypePagesRespectsLimit(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		page, _ := strconv.Atoi(r.URL.Query().Get("pg"))
		_ = json.NewEncoder(w).Encode(map[string]any{
			"code":      1,
			"page":      page,
			"pagecount": 10,
			"total":     100,
			"list": []map[string]any{{
				"vod_id":   page,
				"vod_name": fmt.Sprintf("Title %d", page),
			}},
		})
	}))
	defer server.Close()

	p := New(nil, adapter.NewRegistry(adapter.NewAppleCMS()), true, 0, 3, time.Hour, 8, 4)
	source := &model.Source{APIBase: server.URL}
	pages, err := p.fetchTypePages(context.Background(), source, adapter.NewAppleCMS(), "", 2)
	require.NoError(t, err)
	require.Len(t, pages, 2)
}

func TestWithRetryRetriesTransientFailures(t *testing.T) {
	var attempts atomic.Int32
	value, err := withRetry(context.Background(), func() (string, error) {
		if attempts.Add(1) < 3 {
			return "", fmt.Errorf("temporary")
		}
		return "ok", nil
	})
	require.NoError(t, err)
	require.Equal(t, "ok", value)
	require.Equal(t, int32(3), attempts.Load())
}

func TestWithRetryStopsWhenContextIsCancelled(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	cancel()
	_, err := withRetry(ctx, func() (string, error) {
		return "", fmt.Errorf("temporary")
	})
	require.ErrorIs(t, err, context.Canceled)
}
