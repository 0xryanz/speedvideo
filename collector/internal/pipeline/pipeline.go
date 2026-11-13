// Package pipeline fetches provider pages, normalises them, validates
// renditions and writes them into the catalogue.
package pipeline

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"log/slog"
	"net/url"
	"strings"
	"sync"
	"time"

	"github.com/pagefau1t/speedvideo/collector/internal/adapter"
	"github.com/pagefau1t/speedvideo/collector/internal/model"
	"github.com/pagefau1t/speedvideo/collector/internal/store"
)

// Stats summarises one execution.
type Stats struct {
	Fetched int `json:"fetched"`
	Created int `json:"created"`
	Updated int `json:"updated"`
	Skipped int `json:"skipped"`
	Failed  int `json:"failed"`
}

// Pipeline executes collection jobs.
type Pipeline struct {
	store            *store.Store
	adapters         *adapter.Registry
	allowInsecure    bool
	maxPages         int
	incrementalPages int
	unchangedWindow  time.Duration
}

// New builds a pipeline.
func New(
	store *store.Store,
	adapters *adapter.Registry,
	allowInsecure bool,
	maxPages int,
	incrementalPages int,
	unchangedWindow time.Duration,
) *Pipeline {
	return &Pipeline{
		store:            store,
		adapters:         adapters,
		allowInsecure:    allowInsecure,
		maxPages:         maxPages,
		incrementalPages: incrementalPages,
		unchangedWindow:  unchangedWindow,
	}
}

// Run executes a job and returns its statistics.
func (p *Pipeline) Run(ctx context.Context, job *model.Job) (Stats, error) {
	stats := Stats{}
	source, err := p.store.GetSource(ctx, job.SourceID)
	if err != nil {
		return stats, err
	}
	// Previews and category discovery exist to test a source before it is
	// enabled, so the enabled check only applies to jobs that write the
	// catalogue.
	if job.Kind != "preview" && job.Kind != "types" && !source.Enabled {
		return stats, fmt.Errorf("source %q is disabled", source.Name)
	}
	impl, ok := p.adapters.Get(source.Adapter)
	if !ok {
		return stats, fmt.Errorf("unsupported adapter %q", source.Adapter)
	}

	hosts := map[string]struct{}{}
	switch job.Kind {
	case "title":
		stats.Fetched = 1
		if err := p.collectOne(ctx, source, impl, job.RemoteID, &stats, hosts); err != nil {
			stats.Failed++
			slog.Error("title refresh failed",
				slog.String("source", source.Slug),
				slog.String("remote_id", job.RemoteID),
				slog.String("error", err.Error()))
			return stats, err
		}
	case "preview":
		if err := p.preview(ctx, source, impl, job, &stats); err != nil {
			return stats, err
		}
		return stats, nil
	case "types":
		if err := p.discoverTypes(ctx, source, impl, job, &stats); err != nil {
			return stats, err
		}
		return stats, nil
	case "incremental", "full":
		if err := p.scan(ctx, source, impl, job.Kind, &stats, hosts); err != nil {
			return stats, err
		}
	default:
		return stats, fmt.Errorf("unknown job kind %q", job.Kind)
	}

	if err := p.commitHosts(ctx, source.ID, hosts); err != nil {
		return stats, err
	}
	note := fmt.Sprintf("fetched %d, created %d, updated %d, skipped %d, failed %d",
		stats.Fetched, stats.Created, stats.Updated, stats.Skipped, stats.Failed)
	if len(source.SelectedTypeIDs) > 0 {
		note = fmt.Sprintf("%s, types %d", note, len(source.SelectedTypeIDs))
	}
	if err := p.store.RecordSync(ctx, source.ID, note); err != nil {
		return stats, err
	}
	return stats, nil
}

// scan walks the provider pages. When the operator selected categories, each
// selected category is paged independently and a full scan treats those
// categories as the source's authoritative scope.
func (p *Pipeline) scan(
	ctx context.Context,
	source *model.Source,
	impl adapter.Adapter,
	kind string,
	stats *Stats,
	hosts map[string]struct{},
) error {
	full := kind == "full"
	pages := p.incrementalPages
	if full {
		pages = p.maxPages
		if source.FullScanPages > 0 {
			pages = source.FullScanPages
		}
	}
	scope := make([]string, 0, len(source.SelectedTypeIDs)+1)
	if len(source.SelectedTypeIDs) == 0 {
		scope = append(scope, "")
	} else {
		// Parent categories are folders for most providers; collect their leaf
		// descendants so selecting "电影" works even when the provider does not
		// serve content for the parent id itself.
		scope = append(scope, sourceScope(source)...)
	}

	started := time.Now().UTC()
	seen := map[string]struct{}{}
	for _, typeID := range scope {
		for page := 1; pages <= 0 || page <= pages; page++ {
			var (
				result *adapter.Page
				err    error
			)
			if typeID == "" {
				result, err = impl.List(ctx, source, page)
			} else {
				result, err = impl.ListType(ctx, source, typeID, page)
			}
			if err != nil {
				return fmt.Errorf("list type %q page %d: %w", typeID, page, err)
			}
			if len(result.Items) == 0 {
				break
			}
			for _, item := range result.Items {
				if _, ok := seen[item.RemoteID]; ok {
					continue
				}
				seen[item.RemoteID] = struct{}{}
				stats.Fetched++
				if kind == "incremental" && p.recentlySeen(ctx, source.ID, item.RemoteID) {
					stats.Skipped++
					continue
				}
				if err := p.collectOne(ctx, source, impl, item.RemoteID, stats, hosts); err != nil {
					stats.Failed++
					slog.Warn("provider row rejected",
						slog.String("source", source.Slug),
						slog.String("remote_id", item.RemoteID),
						slog.String("error", err.Error()))
					continue
				}
			}
			if result.PageCount > 0 && page >= result.PageCount {
				break
			}
		}
	}

	if full && stats.Fetched > 0 {
		// A full scan defines the source's authoritative scope, so rows that
		// were not seen — including categories the operator deselected — are
		// tombstoned. The fetched guard prevents an empty provider response
		// from wiping the catalogue.
		if removed, err := p.store.MarkMissing(ctx, source.ID, started); err == nil {
			stats.Skipped += removed
		}
	}
	return nil
}

// discoverTypes caches the provider category tree, with per-category totals, on
// the source and returns it to the console through the job result.
func (p *Pipeline) discoverTypes(
	ctx context.Context,
	source *model.Source,
	impl adapter.Adapter,
	job *model.Job,
	stats *Stats,
) error {
	categories, err := impl.Categories(ctx, source)
	if err != nil {
		return err
	}
	if len(categories) == 0 {
		return fmt.Errorf("provider returned no categories via ac=list")
	}
	stats.Fetched = len(categories)

	// The unfiltered first page yields the page size and overall count used by
	// the console's "how many pages do I need" estimate.
	pageSize := 20
	total := 0
	if page, err := impl.List(ctx, source, 1); err == nil {
		if page.Total > 0 {
			total = page.Total
		}
		if len(page.Items) > 0 {
			pageSize = len(page.Items)
		}
	}
	p.fillCategoryTotals(ctx, source, impl, categories)
	rollUpCategoryTotals(categories)
	if total == 0 {
		for _, category := range categories {
			if category.ParentID == "" {
				total += category.Total
			}
		}
	}

	now := time.Now().UTC()
	snapshot := typeSnapshot{
		Items:        categories,
		Total:        total,
		PageSize:     pageSize,
		DiscoveredAt: now,
	}
	raw, err := json.Marshal(snapshot)
	if err != nil {
		return fmt.Errorf("encode categories: %w", err)
	}
	if err := p.store.SetSourceTypes(ctx, source.ID, string(raw)); err != nil {
		return err
	}
	return p.store.SetJobResult(ctx, job.ID, string(raw))
}

// fillCategoryTotals asks the provider for each category's first page so the
// console can show how many titles a category holds. Best-effort: a failed
// category keeps a zero count instead of failing the whole discovery.
func (p *Pipeline) fillCategoryTotals(
	ctx context.Context,
	source *model.Source,
	impl adapter.Adapter,
	categories []adapter.Category,
) {
	ctx, cancel := context.WithTimeout(ctx, 75*time.Second)
	defer cancel()

	const workers = 6
	sem := make(chan struct{}, workers)
	var wg sync.WaitGroup
	for index := range categories {
		wg.Add(1)
		go func(index int) {
			defer wg.Done()
			select {
			case sem <- struct{}{}:
			case <-ctx.Done():
				return
			}
			defer func() { <-sem }()
			page, err := impl.ListType(ctx, source, categories[index].ID, 1)
			if err != nil {
				return
			}
			categories[index].Total = page.Total
		}(index)
	}
	wg.Wait()
}

// rollUpCategoryTotals replaces a folder category's own (often meaningless)
// count with the sum of its children, which is what viewers understand.
func rollUpCategoryTotals(categories []adapter.Category) {
	sums := make(map[string]int, len(categories))
	for _, category := range categories {
		if category.ParentID != "" {
			sums[category.ParentID] += category.Total
		}
	}
	for index := range categories {
		if categories[index].ParentID != "" {
			continue
		}
		if sum := sums[categories[index].ID]; sum > categories[index].Total {
			categories[index].Total = sum
		}
	}
}

// sourceScope expands selected categories into leaf ids using the cached
// category tree. A stale or missing cache falls back to the raw selection.
func sourceScope(source *model.Source) []string {
	selected := source.SelectedTypeIDs
	categories := cachedCategories(source.Types)
	if len(categories) == 0 {
		return selected
	}
	children := make(map[string][]string, len(categories))
	known := make(map[string]struct{}, len(categories))
	for _, category := range categories {
		known[category.ID] = struct{}{}
		if category.ParentID != "" {
			children[category.ParentID] = append(children[category.ParentID], category.ID)
		}
	}
	out := make([]string, 0, len(selected))
	seen := make(map[string]struct{}, len(selected))
	visiting := make(map[string]struct{}, len(selected))
	var expand func(string)
	expand = func(id string) {
		if _, ok := visiting[id]; ok {
			return
		}
		visiting[id] = struct{}{}
		defer delete(visiting, id)
		if kids := children[id]; len(kids) > 0 {
			for _, kid := range kids {
				expand(kid)
			}
			return
		}
		if _, ok := seen[id]; ok {
			return
		}
		seen[id] = struct{}{}
		out = append(out, id)
	}
	for _, id := range selected {
		if _, ok := known[id]; !ok {
			if _, dup := seen[id]; dup {
				continue
			}
			seen[id] = struct{}{}
			out = append(out, id)
			continue
		}
		expand(id)
	}
	if len(out) == 0 {
		return selected
	}
	return out
}

// cachedCategories accepts both the current snapshot object and the legacy
// bare array stored by earlier releases.
func cachedCategories(raw string) []adapter.Category {
	raw = strings.TrimSpace(raw)
	if raw == "" || raw == "null" {
		return nil
	}
	if strings.HasPrefix(raw, "[") {
		var items []adapter.Category
		if err := json.Unmarshal([]byte(raw), &items); err != nil {
			return nil
		}
		return items
	}
	var snapshot typeSnapshot
	if err := json.Unmarshal([]byte(raw), &snapshot); err != nil {
		return nil
	}
	return snapshot.Items
}

// typeSnapshot is the cached category view: the tree itself plus the counts the
// console uses for its page-limit estimate.
type typeSnapshot struct {
	Items        []adapter.Category `json:"items"`
	Total        int                `json:"total"`
	PageSize     int                `json:"page_size"`
	DiscoveredAt time.Time          `json:"discovered_at"`
}

// preview fetches one provider page and stores a snapshot on the job. It never
// writes the catalogue, which is why it can run against a disabled source.
func (p *Pipeline) preview(
	ctx context.Context,
	source *model.Source,
	impl adapter.Adapter,
	job *model.Job,
	stats *Stats,
) error {
	var options struct {
		Query string `json:"query"`
		Page  int    `json:"page"`
	}
	if job.Payload != "" {
		if err := json.Unmarshal([]byte(job.Payload), &options); err != nil {
			return fmt.Errorf("decode preview payload: %w", err)
		}
	}
	if options.Page < 1 {
		options.Page = 1
	}
	var (
		page *adapter.Page
		err  error
	)
	if strings.TrimSpace(options.Query) == "" {
		page, err = impl.List(ctx, source, options.Page)
	} else {
		page, err = impl.Search(ctx, source, options.Query, options.Page)
	}
	if err != nil {
		return err
	}
	stats.Fetched = len(page.Items)
	raw, err := json.Marshal(page)
	if err != nil {
		return fmt.Errorf("encode preview result: %w", err)
	}
	return p.store.SetJobResult(ctx, job.ID, string(raw))
}

func (p *Pipeline) collectOne(
	ctx context.Context,
	source *model.Source,
	impl adapter.Adapter,
	remoteID string,
	stats *Stats,
	hosts map[string]struct{},
) error {
	title, err := impl.Detail(ctx, source, remoteID)
	if err != nil {
		return err
	}
	if err := p.validate(source, title, hosts); err != nil {
		return err
	}
	_, outcome, err := p.store.UpsertTitle(ctx, source, title, hashOf(title))
	if err != nil {
		return err
	}
	switch outcome {
	case store.OutcomeCreated:
		stats.Created++
	case store.OutcomeUpdated:
		stats.Updated++
	case store.OutcomeUnchanged:
		stats.Skipped++
	}
	return nil
}

// validate refuses renditions the deployment cannot play and records the hosts
// that playback must allow.
func (p *Pipeline) validate(
	source *model.Source,
	title *adapter.Title,
	hosts map[string]struct{},
) error {
	urls := make([]string, 0, len(title.Episodes)+1)
	if title.VideoURL != "" {
		urls = append(urls, title.VideoURL)
	}
	for _, episode := range title.Episodes {
		urls = append(urls, episode.URL)
	}
	if len(urls) == 0 {
		return fmt.Errorf("provider returned no playable rendition")
	}
	for _, raw := range urls {
		parsed, err := url.Parse(raw)
		if err != nil {
			return fmt.Errorf("invalid rendition url: %w", err)
		}
		if parsed.Scheme != "https" && !(p.allowInsecure && parsed.Scheme == "http") {
			return fmt.Errorf("rendition must use https")
		}
		hosts[strings.ToLower(parsed.Hostname())] = struct{}{}
	}
	return nil
}

func (p *Pipeline) commitHosts(
	ctx context.Context,
	sourceID string,
	hosts map[string]struct{},
) error {
	if len(hosts) == 0 {
		return nil
	}
	list := make([]string, 0, len(hosts))
	for host := range hosts {
		list = append(list, host)
	}
	return p.store.AddMediaHosts(ctx, sourceID, list)
}

func (p *Pipeline) recentlySeen(ctx context.Context, sourceID, remoteID string) bool {
	item, err := p.store.FindItem(ctx, sourceID, remoteID)
	if err != nil || item.RemovedAt != nil {
		return false
	}
	return time.Since(item.LastSeenAt) < p.unchangedWindow
}

// hashOf captures everything that should trigger a catalogue write.
func hashOf(title *adapter.Title) string {
	var b strings.Builder
	fmt.Fprintf(&b, "%s|%s|%s|%d|%s|%s|%s", title.Name, title.OriginalName, title.Kind,
		title.Year, title.Synopsis, title.PosterURL, title.VideoURL)
	for _, episode := range title.Episodes {
		fmt.Fprintf(
			&b,
			"|%d:%d:%s:%s",
			episode.SeasonNumber,
			episode.Number,
			episode.Name,
			episode.URL,
		)
	}
	sum := sha256.Sum256([]byte(b.String()))
	return hex.EncodeToString(sum[:])
}
