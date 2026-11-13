// Package service implements the operator use cases for content sources:
// registration, rights attestation, enablement and retirement. The collector
// process consumes whatever is registered here; it never mutates the registry.
package service

import (
	"context"
	"encoding/json"
	"net"
	"net/url"
	"strings"
	"time"

	"github.com/lib/pq"

	"github.com/pagefau1t/speedvideo/api/internal/modules/source/domain"
	"github.com/pagefau1t/speedvideo/api/internal/modules/source/repository"
	"github.com/pagefau1t/speedvideo/api/internal/platform/apperr"
)

// SupportedAdapters lists the wire protocols this deployment can collect.
// Keep in sync with the collector's adapter registry.
var SupportedAdapters = []string{domain.AdapterAppleCMSV10}

// CreateInput is the operator payload for registering a source.
type CreateInput struct {
	Slug             string
	Name             string
	Adapter          string
	APIBase          string
	MediaHosts       []string
	RightsHolder     string
	LicenseReference string
	RightsConfirmed  bool
	Enabled          bool
}

// UpdateInput is a partial update. Nil fields are left untouched.
type UpdateInput struct {
	Name             *string
	APIBase          *string
	MediaHosts       *[]string
	RightsHolder     *string
	LicenseReference *string
	Enabled          *bool
	SelectedTypeIDs  *[]string
	FullScanPages    *int
}

// TypeSnapshot is the cached provider category tree plus collection totals.
// Counts come from the provider's list endpoint and are refreshed by the
// collector during category discovery.
type TypeSnapshot struct {
	Items    []domain.Category `json:"items"`
	Total    int               `json:"total"`
	PageSize int               `json:"page_size"`
}

// Service owns source registration rules.
type Service struct {
	repo          *repository.Repository
	allowInsecure bool
}

// New builds the service. allowInsecure is development-only and relaxes the
// https requirement so a local fixture can be used.
func New(repo *repository.Repository, allowInsecure bool) *Service {
	return &Service{repo: repo, allowInsecure: allowInsecure}
}

// List returns every registered source.
func (s *Service) List(ctx context.Context) ([]domain.Source, error) {
	return s.repo.List(ctx)
}

// Get loads one source.
func (s *Service) Get(ctx context.Context, id string) (*domain.Source, error) {
	return s.repo.FindByID(ctx, id)
}

// Create validates and stores a new source.
func (s *Service) Create(ctx context.Context, in CreateInput) (*domain.Source, error) {
	if !in.RightsConfirmed {
		return nil, apperr.New(apperr.KindValidation,
			"rights confirmation is required before a source can be registered")
	}
	adapter := strings.TrimSpace(in.Adapter)
	if adapter == "" {
		adapter = domain.AdapterAppleCMSV10
	}
	if !supportedAdapter(adapter) {
		return nil, apperr.New(apperr.KindValidation, "unsupported adapter %q", adapter)
	}
	apiBase, err := s.normaliseAPIBase(in.APIBase)
	if err != nil {
		return nil, err
	}

	name := strings.TrimSpace(in.Name)
	if name == "" {
		if parsed, parseErr := url.Parse(apiBase); parseErr == nil {
			name = parsed.Hostname()
		}
	}
	if name == "" {
		return nil, apperr.New(apperr.KindValidation, "name is required")
	}

	slug := slugify(in.Slug)
	if slug == "" {
		slug = slugify(name)
	}
	if slug == "" {
		slug = "source"
	}
	if _, err := s.repo.FindBySlug(ctx, slug); err == nil {
		return nil, apperr.New(apperr.KindConflict, "a source with this slug already exists")
	} else if !apperr.IsKind(err, apperr.KindNotFound) {
		return nil, err
	}

	hosts := normaliseHosts(in.MediaHosts)
	if len(hosts) == 0 {
		if parsed, parseErr := url.Parse(apiBase); parseErr == nil {
			hosts = []string{strings.ToLower(parsed.Hostname())}
		}
	}
	now := time.Now().UTC()
	source := &domain.Source{
		Slug:              slug,
		Name:              name,
		Adapter:           adapter,
		APIBase:           apiBase,
		MediaHosts:        hosts,
		Enabled:           in.Enabled,
		Types:             "[]",
		SelectedTypeIDs:   pq.StringArray{},
		RightsHolder:      strings.TrimSpace(in.RightsHolder),
		LicenseReference:  strings.TrimSpace(in.LicenseReference),
		RightsConfirmedAt: &now,
	}
	if err := s.repo.Create(ctx, source); err != nil {
		return nil, err
	}
	return source, nil
}

// Update applies a partial change. Enabling requires an attested source.
func (s *Service) Update(ctx context.Context, id string, in UpdateInput) (*domain.Source, error) {
	source, err := s.repo.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if in.Name != nil {
		name := strings.TrimSpace(*in.Name)
		if name == "" {
			return nil, apperr.New(apperr.KindValidation, "name must not be empty")
		}
		source.Name = name
	}
	if in.APIBase != nil {
		apiBase, err := s.normaliseAPIBase(*in.APIBase)
		if err != nil {
			return nil, err
		}
		source.APIBase = apiBase
	}
	if in.MediaHosts != nil {
		hosts := normaliseHosts(*in.MediaHosts)
		if len(hosts) == 0 {
			return nil, apperr.New(apperr.KindValidation, "at least one media host is required")
		}
		source.MediaHosts = hosts
	}
	if in.RightsHolder != nil {
		source.RightsHolder = strings.TrimSpace(*in.RightsHolder)
	}
	if in.LicenseReference != nil {
		source.LicenseReference = strings.TrimSpace(*in.LicenseReference)
	}
	if in.Enabled != nil {
		if *in.Enabled && source.RightsConfirmedAt == nil {
			return nil, apperr.New(apperr.KindValidation, "confirm the distribution rights first")
		}
		source.Enabled = *in.Enabled
	}
	if in.SelectedTypeIDs != nil {
		ids, err := normaliseTypeIDs(*in.SelectedTypeIDs)
		if err != nil {
			return nil, err
		}
		source.SelectedTypeIDs = ids
	}
	if in.FullScanPages != nil {
		if *in.FullScanPages < 0 || *in.FullScanPages > 10000 {
			return nil, apperr.New(
				apperr.KindValidation,
				"full_scan_pages must be between 0 and 10000",
			)
		}
		source.FullScanPages = *in.FullScanPages
	}
	if err := s.repo.Update(ctx, source); err != nil {
		return nil, err
	}
	return source, nil
}

// TypeSnapshot returns the category list cached by the collector. Older
// installs stored a bare array, so both shapes are accepted.
func (s *Service) TypeSnapshot(ctx context.Context, id string) (*TypeSnapshot, error) {
	source, err := s.repo.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}
	raw := strings.TrimSpace(source.Types)
	if raw == "" || raw == "null" {
		return &TypeSnapshot{Items: []domain.Category{}, PageSize: 20}, nil
	}
	if strings.HasPrefix(raw, "[") {
		var items []domain.Category
		if err := json.Unmarshal([]byte(raw), &items); err != nil {
			return nil, apperr.New(apperr.KindUnknown, "cached category list is corrupt")
		}
		if items == nil {
			items = []domain.Category{}
		}
		snapshot := &TypeSnapshot{Items: items, PageSize: 20}
		for _, item := range items {
			if item.ParentID == "" {
				snapshot.Total += item.Total
			}
		}
		return snapshot, nil
	}
	var snapshot TypeSnapshot
	if err := json.Unmarshal([]byte(raw), &snapshot); err != nil {
		return nil, apperr.New(apperr.KindUnknown, "cached category list is corrupt")
	}
	if snapshot.Items == nil {
		snapshot.Items = []domain.Category{}
	}
	if snapshot.PageSize <= 0 {
		snapshot.PageSize = 20
	}
	if snapshot.Total == 0 {
		for _, item := range snapshot.Items {
			if item.ParentID == "" {
				snapshot.Total += item.Total
			}
		}
	}
	return &snapshot, nil
}

// Delete retires a source. Collected rows are kept so history survives; the
// catalogue hides them immediately because the source is gone.
func (s *Service) Delete(ctx context.Context, id string) error {
	if _, err := s.repo.FindByID(ctx, id); err != nil {
		return err
	}
	return s.repo.Delete(ctx, id)
}

func (s *Service) normaliseAPIBase(raw string) (string, error) {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return "", apperr.New(apperr.KindValidation, "api_base is required")
	}
	parsed, err := url.Parse(raw)
	if err != nil || parsed.Host == "" {
		return "", apperr.New(apperr.KindValidation, "api_base must be an absolute url")
	}
	if parsed.Scheme != "https" && !(s.allowInsecure && parsed.Scheme == "http") {
		return "", apperr.New(apperr.KindValidation, "api_base must use https")
	}
	if parsed.User != nil {
		return "", apperr.New(apperr.KindValidation, "api_base must not contain credentials")
	}
	if blockedHost(strings.ToLower(parsed.Hostname())) {
		return "", apperr.New(apperr.KindValidation, "api_base must not point at a private address")
	}
	return parsed.String(), nil
}

func blockedHost(host string) bool {
	if host == "" || host == "localhost" || strings.HasSuffix(host, ".local") {
		return true
	}
	if ip := net.ParseIP(host); ip != nil {
		return ip.IsLoopback() || ip.IsPrivate() || ip.IsLinkLocalUnicast() || ip.IsUnspecified()
	}
	return false
}

func normaliseHosts(hosts []string) []string {
	out := make([]string, 0, len(hosts))
	seen := map[string]struct{}{}
	for _, raw := range hosts {
		host := strings.ToLower(strings.TrimSpace(raw))
		if host == "" || strings.Contains(host, "*") {
			continue
		}
		if parsed, err := url.Parse(host); err == nil && parsed.Hostname() != "" {
			host = strings.ToLower(parsed.Hostname())
		}
		host = strings.TrimSuffix(host, ".")
		if host == "" || strings.Contains(host, "/") {
			continue
		}
		if _, ok := seen[host]; ok {
			continue
		}
		seen[host] = struct{}{}
		out = append(out, host)
	}
	return out
}

func normaliseTypeIDs(ids []string) (pq.StringArray, error) {
	out := pq.StringArray{}
	seen := map[string]struct{}{}
	for _, raw := range ids {
		id := strings.TrimSpace(raw)
		if id == "" {
			continue
		}
		if len(id) > 64 {
			return nil, apperr.New(apperr.KindValidation, "category id is too long")
		}
		if _, ok := seen[id]; ok {
			continue
		}
		seen[id] = struct{}{}
		out = append(out, id)
	}
	if len(out) > 500 {
		return nil, apperr.New(apperr.KindValidation, "at most 500 categories can be selected")
	}
	return out, nil
}

func supportedAdapter(adapter string) bool {
	for _, item := range SupportedAdapters {
		if item == adapter {
			return true
		}
	}
	return false
}

func slugify(raw string) string {
	raw = strings.TrimSpace(strings.ToLower(raw))
	var b strings.Builder
	lastDash := false
	for _, r := range raw {
		switch {
		case r >= 'a' && r <= 'z', r >= '0' && r <= '9':
			b.WriteRune(r)
			lastDash = false
		case r > 127:
			b.WriteRune(r)
			lastDash = false
		default:
			if !lastDash && b.Len() > 0 {
				b.WriteByte('-')
				lastDash = true
			}
		}
	}
	return strings.Trim(b.String(), "-")
}
