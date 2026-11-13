package adapter

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/pagefau1t/speedvideo/collector/internal/model"
)

func TestAppleCMSSearchParsesRenditions(t *testing.T) {
	payload := map[string]any{
		"code": 1, "page": 1, "pagecount": 1, "total": 1,
		"list": []map[string]any{{
			"vod_id": 7, "vod_name": "Example Series", "vod_year": "2024",
			"vod_pic": "http://img.example.com/poster.jpg", "type_name": "国产剧",
			"vod_content":   "<p>A <b>long</b> synopsis.</p>",
			"vod_play_from": "ffmpeg$$$m3u8",
			"vod_play_url":  "第01集$http://cdn.example.com/1.m3u8#第02集$http://cdn.example.com/2.m3u8",
		}},
	}
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		require.Equal(t, "videolist", r.URL.Query().Get("ac"))
		require.Equal(t, "example", r.URL.Query().Get("wd"))
		_ = json.NewEncoder(w).Encode(payload)
	}))
	defer server.Close()

	impl := NewAppleCMS()
	page, err := impl.Search(context.Background(), &model.Source{APIBase: server.URL}, "example", 1)
	require.NoError(t, err)
	require.Len(t, page.Items, 1)

	title := page.Items[0]
	require.Equal(t, "7", title.RemoteID)
	require.Equal(t, "series", title.Kind)
	require.Equal(t, 2024, title.Year)
	require.Equal(t, "A long synopsis.", title.Synopsis)
	require.Len(t, title.Episodes, 2)
	require.Equal(t, "http://cdn.example.com/1.m3u8", title.Episodes[0].URL)
	require.Equal(t, 2, title.Episodes[1].Number)
}

func TestAppleCMSMovieUsesSingleRendition(t *testing.T) {
	payload := map[string]any{
		"code": 1,
		"list": []map[string]any{{
			"vod_id": "42", "vod_name": "Example Movie", "type_name": "动作片",
			"vod_play_from": "m3u8",
			"vod_play_url":  "正片$http://cdn.example.com/movie/index.m3u8",
		}},
	}
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_ = json.NewEncoder(w).Encode(payload)
	}))
	defer server.Close()

	impl := NewAppleCMS()
	title, err := impl.Detail(context.Background(), &model.Source{APIBase: server.URL}, "42")
	require.NoError(t, err)
	require.Equal(t, "movie", title.Kind)
	require.Empty(t, title.Episodes)
	require.Equal(t, "http://cdn.example.com/movie/index.m3u8", title.VideoURL)
}

func TestAppleCMSListsCategories(t *testing.T) {
	payload := map[string]any{
		"code": 1,
		"class": []map[string]any{
			{"type_id": 1, "type_pid": 0, "type_name": "电影"},
			{"type_id": "2", "type_pid": "0", "type_name": "连续剧"},
			{"type_id": 3, "type_pid": 1, "type_name": "动作片"},
			{"type_id": 1, "type_pid": 0, "type_name": "电影"},
			{"type_id": 9, "type_pid": 0, "type_name": ""},
		},
	}
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		require.Equal(t, "list", r.URL.Query().Get("ac"))
		_ = json.NewEncoder(w).Encode(payload)
	}))
	defer server.Close()

	categories, err := NewAppleCMS().Categories(context.Background(), &model.Source{APIBase: server.URL})
	require.NoError(t, err)
	require.Len(t, categories, 3)
	require.Equal(t, Category{ID: "1", Name: "电影"}, categories[0])
	require.Equal(t, Category{ID: "2", Name: "连续剧"}, categories[1])
	require.Equal(t, Category{ID: "3", Name: "动作片", ParentID: "1"}, categories[2])
}

func TestAppleCMSListTypeFiltersByCategory(t *testing.T) {
	payload := map[string]any{
		"code": 1, "page": 2, "pagecount": 4, "total": 80,
		"list": []map[string]any{{
			"vod_id": "11", "vod_name": "Example", "type_name": "电影",
			"vod_play_from": "m3u8",
			"vod_play_url":  "正片$http://cdn.example.com/movie.m3u8",
		}},
	}
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		require.Equal(t, "videolist", r.URL.Query().Get("ac"))
		require.Equal(t, "3", r.URL.Query().Get("t"))
		require.Equal(t, "2", r.URL.Query().Get("pg"))
		_ = json.NewEncoder(w).Encode(payload)
	}))
	defer server.Close()

	page, err := NewAppleCMS().ListType(context.Background(), &model.Source{APIBase: server.URL}, "3", 2)
	require.NoError(t, err)
	require.Len(t, page.Items, 1)
	require.Equal(t, 4, page.PageCount)
	require.Equal(t, 80, page.Total)
}

func TestAppleCMSDropsMalformedRows(t *testing.T) {
	payload := map[string]any{
		"code": 1,
		"list": []map[string]any{
			{"vod_name": "no id"},
			{"vod_id": "9", "vod_name": "Valid"},
		},
	}
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_ = json.NewEncoder(w).Encode(payload)
	}))
	defer server.Close()

	page, err := NewAppleCMS().List(context.Background(), &model.Source{APIBase: server.URL}, 1)
	require.NoError(t, err)
	require.Len(t, page.Items, 1)
	require.Equal(t, "Valid", page.Items[0].Name)
}
