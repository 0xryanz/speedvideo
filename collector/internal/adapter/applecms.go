package adapter

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"regexp"
	"strconv"
	"strings"
	"time"

	"github.com/pagefau1t/speedvideo/collector/internal/model"
)

// AppleCMS implements the documented 苹果CMS V10 `provide/vod` JSON protocol.
type AppleCMS struct {
	client *http.Client
}

// NewAppleCMS builds the adapter with a bounded HTTP client.
func NewAppleCMS() *AppleCMS {
	return &AppleCMS{client: &http.Client{
		Timeout: 20 * time.Second,
		CheckRedirect: func(req *http.Request, via []*http.Request) error {
			if len(via) >= 3 {
				return http.ErrUseLastResponse
			}
			return nil
		},
	}}
}

// Kind returns the adapter identifier.
func (a *AppleCMS) Kind() string { return "apple_cms_v10" }

const maxProviderBody = 8 << 20

// Search performs a keyword query.
func (a *AppleCMS) Search(
	ctx context.Context,
	src *model.Source,
	query string,
	page int,
) (*Page, error) {
	return a.fetch(ctx, src, url.Values{
		"ac": {"videolist"},
		"wd": {query},
		"pg": {strconv.Itoa(normalisePage(page))},
	})
}

// List returns the provider's newest titles.
func (a *AppleCMS) List(ctx context.Context, src *model.Source, page int) (*Page, error) {
	return a.fetch(ctx, src, url.Values{
		"ac": {"videolist"},
		"pg": {strconv.Itoa(normalisePage(page))},
	})
}

// ListType returns one page restricted to a provider category.
func (a *AppleCMS) ListType(
	ctx context.Context,
	src *model.Source,
	typeID string,
	page int,
) (*Page, error) {
	typeID = strings.TrimSpace(typeID)
	if typeID == "" {
		return a.List(ctx, src, page)
	}
	return a.fetch(ctx, src, url.Values{
		"ac": {"videolist"},
		"t":  {typeID},
		"pg": {strconv.Itoa(normalisePage(page))},
	})
}

// Categories reads the provider's category tree via `ac=list`. AppleCMS V10
// returns it in the `class` array; the video list on the same response is not
// used here.
func (a *AppleCMS) Categories(ctx context.Context, src *model.Source) ([]Category, error) {
	payload, err := a.fetchPayload(ctx, src, url.Values{"ac": {"list"}})
	if err != nil {
		return nil, err
	}
	out := make([]Category, 0, len(payload.Class))
	seen := make(map[string]struct{}, len(payload.Class))
	for _, item := range payload.Class {
		id := strings.TrimSpace(string(item.TypeID))
		name := strings.TrimSpace(item.TypeName)
		if id == "" || name == "" {
			continue
		}
		if _, ok := seen[id]; ok {
			continue
		}
		seen[id] = struct{}{}
		parent := strings.TrimSpace(string(item.TypePID))
		if parent == "0" {
			parent = ""
		}
		out = append(out, Category{ID: id, Name: name, ParentID: parent})
	}
	return out, nil
}

// Detail loads one title with its playable renditions.
func (a *AppleCMS) Detail(ctx context.Context, src *model.Source, remoteID string) (*Title, error) {
	if strings.TrimSpace(remoteID) == "" {
		return nil, fmt.Errorf("remote id is required")
	}
	page, err := a.fetch(ctx, src, url.Values{
		"ac":  {"detail"},
		"ids": {remoteID},
	})
	if err != nil {
		return nil, err
	}
	if len(page.Items) == 0 {
		page, err = a.fetch(ctx, src, url.Values{
			"ac":  {"videolist"},
			"ids": {remoteID},
		})
		if err != nil {
			return nil, err
		}
	}
	if len(page.Items) == 0 {
		return nil, fmt.Errorf("provider returned no title for id %q", remoteID)
	}
	title := page.Items[0]
	return &title, nil
}

func (a *AppleCMS) fetch(ctx context.Context, src *model.Source, params url.Values) (*Page, error) {
	payload, err := a.fetchPayload(ctx, src, params)
	if err != nil {
		return nil, err
	}

	page := &Page{Page: payload.Page, PageCount: payload.PageCount, Total: payload.Total}
	for _, item := range payload.List {
		title, err := item.toTitle()
		if err != nil {
			continue
		}
		page.Items = append(page.Items, title)
	}
	return page, nil
}

func (a *AppleCMS) fetchPayload(
	ctx context.Context,
	src *model.Source,
	params url.Values,
) (*vodResponse, error) {
	endpoint, err := url.Parse(src.APIBase)
	if err != nil {
		return nil, fmt.Errorf("parse provider endpoint: %w", err)
	}
	query := endpoint.Query()
	for key, values := range params {
		query.Set(key, values[0])
	}
	endpoint.RawQuery = query.Encode()

	request, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint.String(), nil)
	if err != nil {
		return nil, fmt.Errorf("build provider request: %w", err)
	}
	request.Header.Set("Accept", "application/json")
	request.Header.Set("User-Agent", "speedvideo-collector/1.0")

	response, err := a.client.Do(request)
	if err != nil {
		return nil, fmt.Errorf("request provider: %w", err)
	}
	defer func() {
		_, _ = io.Copy(io.Discard, io.LimitReader(response.Body, 1<<20))
		_ = response.Body.Close()
	}()
	if response.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("provider responded with status %d", response.StatusCode)
	}

	var payload vodResponse
	decoder := json.NewDecoder(io.LimitReader(response.Body, maxProviderBody))
	if err := decoder.Decode(&payload); err != nil {
		return nil, fmt.Errorf("decode provider response: %w", err)
	}
	if payload.Code != 0 && payload.Code != 1 {
		return nil, fmt.Errorf("provider error %d: %s", payload.Code, payload.Msg)
	}
	return &payload, nil
}

type vodResponse struct {
	Code      int        `json:"code"`
	Msg       string     `json:"msg"`
	Page      int        `json:"page"`
	PageCount int        `json:"pagecount"`
	Total     int        `json:"total"`
	List      []vodItem  `json:"list"`
	Class     []vodClass `json:"class"`
}

type vodClass struct {
	TypeID   flexString `json:"type_id"`
	TypePID  flexString `json:"type_pid"`
	TypeName string     `json:"type_name"`
}

type vodItem struct {
	VodID       flexString `json:"vod_id"`
	VodName     string     `json:"vod_name"`
	VodSub      string     `json:"vod_sub"`
	VodPic      string     `json:"vod_pic"`
	VodYear     flexString `json:"vod_year"`
	VodArea     string     `json:"vod_area"`
	VodRemarks  string     `json:"vod_remarks"`
	TypeName    string     `json:"type_name"`
	VodContent  string     `json:"vod_content"`
	VodPlayFrom string     `json:"vod_play_from"`
	VodPlayURL  string     `json:"vod_play_url"`
}

func (item vodItem) toTitle() (Title, error) {
	remoteID := strings.TrimSpace(string(item.VodID))
	name := strings.TrimSpace(item.VodName)
	if remoteID == "" || name == "" {
		return Title{}, fmt.Errorf("provider row is missing an id or name")
	}
	year, _ := strconv.Atoi(strings.TrimSpace(string(item.VodYear)))

	episodes := pickPlaylist(item.VodPlayFrom, item.VodPlayURL)
	kind := inferKind(item.TypeName, episodes)
	title := Title{
		RemoteID:     remoteID,
		Name:         name,
		OriginalName: strings.TrimSpace(item.VodSub),
		Kind:         kind,
		PosterURL:    cleanURL(item.VodPic),
		Synopsis:     stripHTML(item.VodContent),
		Year:         year,
		Genres:       splitGenres(item.TypeName),
	}
	if title.OriginalName == "" {
		title.OriginalName = name
	}
	if kind == "series" {
		title.Episodes = episodes
	}
	if kind == "movie" && len(episodes) > 0 {
		title.VideoURL = episodes[0].URL
	}
	return title, nil
}

func pickPlaylist(from, raw string) []Episode {
	groups := strings.Split(raw, "$$$")
	lines := strings.Split(from, "$$$")
	bestScore := -1
	var best []Episode
	for index, group := range groups {
		if strings.TrimSpace(group) == "" {
			continue
		}
		episodes := parseGroup(group)
		if len(episodes) == 0 {
			continue
		}
		score := 0
		for _, episode := range episodes {
			if strings.Contains(episode.URL, ".m3u8") {
				score += 2
			}
			if strings.HasPrefix(episode.URL, "https://") {
				score++
			}
			if index < len(lines) && strings.Contains(strings.ToLower(lines[index]), "m3u8") {
				score++
			}
		}
		if score > bestScore {
			bestScore = score
			best = episodes
		}
	}
	return best
}

var episodeNumber = regexp.MustCompile(`(?i)(?:第\s*|ep|e)\s*(\d{1,4})\s*(?:集|话|期)?`)

func parseGroup(group string) []Episode {
	parts := strings.Split(group, "#")
	episodes := make([]Episode, 0, len(parts))
	for index, part := range parts {
		part = strings.TrimSpace(part)
		if part == "" {
			continue
		}
		name := ""
		link := part
		if before, after, ok := strings.Cut(part, "$"); ok {
			name = strings.TrimSpace(before)
			link = strings.TrimSpace(after)
		}
		link = cleanURL(link)
		if link == "" {
			continue
		}
		number := index + 1
		if match := episodeNumber.FindStringSubmatch(name); len(match) == 2 {
			if parsed, err := strconv.Atoi(match[1]); err == nil && parsed > 0 {
				number = parsed
			}
		}
		if name == "" {
			name = fmt.Sprintf("Episode %d", number)
		}
		episodes = append(episodes, Episode{
			SeasonNumber: 1,
			Number:       number,
			Name:         name,
			URL:          link,
		})
	}
	return episodes
}

func inferKind(typeName string, episodes []Episode) string {
	for _, marker := range []string{"剧", "动漫", "动画", "综艺", "纪录"} {
		if strings.Contains(typeName, marker) {
			return "series"
		}
	}
	if len(episodes) > 1 {
		return "series"
	}
	return "movie"
}

func splitGenres(typeName string) []string {
	fields := strings.FieldsFunc(typeName, func(r rune) bool {
		return r == ',' || r == '/' || r == '、' || r == ' '
	})
	genres := make([]string, 0, len(fields))
	for _, field := range fields {
		field = strings.TrimSpace(field)
		if field != "" {
			genres = append(genres, field)
		}
	}
	return genres
}

func cleanURL(raw string) string {
	raw = strings.TrimSpace(raw)
	if strings.HasPrefix(raw, "//") {
		return "https:" + raw
	}
	return raw
}

func stripHTML(raw string) string {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return ""
	}
	var b strings.Builder
	inTag := false
	for _, r := range raw {
		switch {
		case r == '<':
			inTag = true
		case r == '>':
			inTag = false
		case !inTag:
			b.WriteRune(r)
		}
	}
	return strings.Join(strings.Fields(b.String()), " ")
}

func normalisePage(page int) int {
	if page < 1 {
		return 1
	}
	return page
}

type flexString string

func (f *flexString) UnmarshalJSON(data []byte) error {
	trimmed := strings.TrimSpace(string(data))
	if trimmed == "null" {
		*f = ""
		return nil
	}
	if strings.HasPrefix(trimmed, `"`) {
		var value string
		if err := json.Unmarshal(data, &value); err != nil {
			return err
		}
		*f = flexString(value)
		return nil
	}
	*f = flexString(strings.Trim(trimmed, `"`))
	return nil
}
