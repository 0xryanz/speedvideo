// Package httpapi is the operations transport. It exposes the collection
// control plane (sources, jobs, runs, items) on the API process, guarded by a
// shared admin token. The collector itself runs no HTTP server: it only leases
// jobs from the database and executes them.
package httpapi

import (
	"context"
	"encoding/json"
	"log/slog"
	"net/http"
	"net/url"
	"strconv"

	"github.com/go-chi/chi/v5"

	"github.com/pagefau1t/speedvideo/api/internal/modules/collector/domain"
	"github.com/pagefau1t/speedvideo/api/internal/modules/collector/repository"
	collectorservice "github.com/pagefau1t/speedvideo/api/internal/modules/collector/service"
	sourceservice "github.com/pagefau1t/speedvideo/api/internal/modules/source/service"
	"github.com/pagefau1t/speedvideo/api/internal/platform/apperr"
	"github.com/pagefau1t/speedvideo/api/internal/platform/httpx"
)

// canonicalRefresher re-elects the visible rendition of a work after a source
// changes state. Implemented by the catalog module.
type canonicalRefresher interface {
	RefreshSourceCanonical(ctx context.Context, sourceID string) error
}

// Handler exposes the collection control plane.
type Handler struct {
	sources   *sourceservice.Service
	collector *collectorservice.Service
	catalogue canonicalRefresher
	log       *slog.Logger
}

// New builds the admin transport.
func New(
	sources *sourceservice.Service,
	collector *collectorservice.Service,
	catalogue canonicalRefresher,
	log *slog.Logger,
) *Handler {
	return &Handler{
		sources:   sources,
		collector: collector,
		catalogue: catalogue,
		log:       log.With(slog.String("module", "admin")),
	}
}

// Routes mounts the admin endpoints on an already-authenticated group.
func (h *Handler) Routes(r chi.Router) {
	r.Get("/stats", h.stats)
	r.Get("/adapters", h.adapters)

	r.Get("/sources", h.listSources)
	r.Post("/sources", h.createSource)
	r.Get("/sources/{id}", h.getSource)
	r.Patch("/sources/{id}", h.updateSource)
	r.Delete("/sources/{id}", h.deleteSource)
	r.Post("/sources/{id}/sync", h.syncSource)
	r.Post("/sources/{id}/preview", h.previewSource)
	r.Get("/sources/{id}/types", h.sourceTypes)
	r.Post("/sources/{id}/types/discover", h.discoverSourceTypes)

	r.Get("/jobs", h.listJobs)
	r.Get("/jobs/{id}", h.getJob)
	r.Post("/jobs/{id}/retry", h.retryJob)
	r.Post("/titles/{id}/refresh", h.refreshTitle)

	r.Get("/runs", h.listRuns)
	r.Get("/items", h.listItems)
}

func (h *Handler) stats(w http.ResponseWriter, r *http.Request) {
	stats, err := h.collector.Stats(r.Context())
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, stats)
}

func (h *Handler) adapters(w http.ResponseWriter, r *http.Request) {
	httpx.WriteJSON(w, http.StatusOK, map[string]any{"items": sourceservice.SupportedAdapters})
}

func (h *Handler) listSources(w http.ResponseWriter, r *http.Request) {
	sources, err := h.sources.List(r.Context())
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, map[string]any{"items": sources})
}

type createSourceRequest struct {
	Slug             string   `json:"slug"`
	Name             string   `json:"name"`
	Adapter          string   `json:"adapter"`
	APIBase          string   `json:"api_base"`
	MediaHosts       []string `json:"media_hosts"`
	RightsHolder     string   `json:"rights_holder"`
	LicenseReference string   `json:"license_reference"`
	RightsConfirmed  bool     `json:"rights_confirmed"`
	Enabled          bool     `json:"enabled"`
}

func (h *Handler) createSource(w http.ResponseWriter, r *http.Request) {
	var body createSourceRequest
	if err := httpx.DecodeJSON(w, r, &body); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	source, err := h.sources.Create(r.Context(), sourceservice.CreateInput{
		Slug:             body.Slug,
		Name:             body.Name,
		Adapter:          body.Adapter,
		APIBase:          body.APIBase,
		MediaHosts:       body.MediaHosts,
		RightsHolder:     body.RightsHolder,
		LicenseReference: body.LicenseReference,
		RightsConfirmed:  body.RightsConfirmed,
		Enabled:          body.Enabled,
	})
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusCreated, source)
}

func (h *Handler) getSource(w http.ResponseWriter, r *http.Request) {
	source, err := h.sources.Get(r.Context(), chi.URLParam(r, "id"))
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, source)
}

type updateSourceRequest struct {
	Name             *string   `json:"name"`
	APIBase          *string   `json:"api_base"`
	MediaHosts       *[]string `json:"media_hosts"`
	RightsHolder     *string   `json:"rights_holder"`
	LicenseReference *string   `json:"license_reference"`
	Enabled          *bool     `json:"enabled"`
	SelectedTypeIDs  *[]string `json:"selected_type_ids"`
	FullScanPages    *int      `json:"full_scan_pages"`
}

func (h *Handler) updateSource(w http.ResponseWriter, r *http.Request) {
	var body updateSourceRequest
	if err := httpx.DecodeJSON(w, r, &body); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	updated, err := h.sources.Update(r.Context(), chi.URLParam(r, "id"), sourceservice.UpdateInput{
		Name:             body.Name,
		APIBase:          body.APIBase,
		MediaHosts:       body.MediaHosts,
		RightsHolder:     body.RightsHolder,
		LicenseReference: body.LicenseReference,
		Enabled:          body.Enabled,
		SelectedTypeIDs:  body.SelectedTypeIDs,
		FullScanPages:    body.FullScanPages,
	})
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	if err := h.catalogue.RefreshSourceCanonical(r.Context(), updated.ID); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, updated)
}

func (h *Handler) deleteSource(w http.ResponseWriter, r *http.Request) {
	sourceID := chi.URLParam(r, "id")
	if err := h.sources.Delete(r.Context(), sourceID); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	if err := h.catalogue.RefreshSourceCanonical(r.Context(), sourceID); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

type syncRequest struct {
	Kind string `json:"kind"`
}

func (h *Handler) syncSource(w http.ResponseWriter, r *http.Request) {
	sourceID := chi.URLParam(r, "id")
	source, err := h.sources.Get(r.Context(), sourceID)
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	if !source.Enabled {
		httpx.WriteError(
			w,
			r,
			h.log,
			apperr.New(apperr.KindConflict, "enable the source before syncing"),
		)
		return
	}
	var body syncRequest
	if r.ContentLength > 0 {
		if err := httpx.DecodeJSON(w, r, &body); err != nil {
			httpx.WriteError(w, r, h.log, err)
			return
		}
	}
	job, err := h.collector.EnqueueSync(r.Context(), sourceID, body.Kind)
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusAccepted, jobDetail(job))
}

type previewRequest struct {
	Query string `json:"query"`
	Page  int    `json:"page"`
}

func (h *Handler) previewSource(w http.ResponseWriter, r *http.Request) {
	sourceID := chi.URLParam(r, "id")
	if _, err := h.sources.Get(r.Context(), sourceID); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	var body previewRequest
	if r.ContentLength > 0 {
		if err := httpx.DecodeJSON(w, r, &body); err != nil {
			httpx.WriteError(w, r, h.log, err)
			return
		}
	}
	job, err := h.collector.EnqueuePreview(r.Context(), sourceID, body.Query, body.Page)
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusAccepted, jobDetail(job))
}

// sourceTypes returns the category list the collector cached on the source,
// together with the operator's current scope. The API never calls the provider.
func (h *Handler) sourceTypes(w http.ResponseWriter, r *http.Request) {
	sourceID := chi.URLParam(r, "id")
	source, err := h.sources.Get(r.Context(), sourceID)
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	categories, err := h.sources.TypeSnapshot(r.Context(), sourceID)
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	selected := make([]string, 0, len(source.SelectedTypeIDs))
	selected = append(selected, source.SelectedTypeIDs...)
	httpx.WriteJSON(w, http.StatusOK, map[string]any{
		"items":             categories.Items,
		"total":             categories.Total,
		"page_size":         categories.PageSize,
		"selected_type_ids": selected,
		"full_scan_pages":   source.FullScanPages,
	})
}

// discoverSourceTypes queues a collector job that reads the provider's category
// list. It works on disabled sources so an operator can scope before enabling.
func (h *Handler) discoverSourceTypes(w http.ResponseWriter, r *http.Request) {
	sourceID := chi.URLParam(r, "id")
	if _, err := h.sources.Get(r.Context(), sourceID); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	job, err := h.collector.EnqueueTypeDiscovery(r.Context(), sourceID)
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusAccepted, jobDetail(job))
}

func (h *Handler) listJobs(w http.ResponseWriter, r *http.Request) {
	query := r.URL.Query()
	jobs, total, err := h.collector.ListJobs(r.Context(), repository.Filter{
		SourceID: query.Get("source_id"),
		Status:   query.Get("status"),
		Kind:     query.Get("kind"),
		Limit:    intParam(query, "limit", 50),
		Offset:   intParam(query, "offset", 0),
	})
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, map[string]any{
		"items":  jobs,
		"total":  total,
		"limit":  intParam(query, "limit", 50),
		"offset": intParam(query, "offset", 0),
	})
}

func (h *Handler) getJob(w http.ResponseWriter, r *http.Request) {
	job, err := h.collector.GetJob(r.Context(), chi.URLParam(r, "id"))
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, jobDetail(job))
}

func (h *Handler) retryJob(w http.ResponseWriter, r *http.Request) {
	job, err := h.collector.RetryJob(r.Context(), chi.URLParam(r, "id"))
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusAccepted, jobDetail(job))
}

func (h *Handler) refreshTitle(w http.ResponseWriter, r *http.Request) {
	job, err := h.collector.EnqueueTitleRefresh(r.Context(), chi.URLParam(r, "id"))
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusAccepted, jobDetail(job))
}

func (h *Handler) listRuns(w http.ResponseWriter, r *http.Request) {
	query := r.URL.Query()
	runs, total, err := h.collector.ListRuns(r.Context(), repository.RunFilter{
		SourceID: query.Get("source_id"),
		Kind:     query.Get("kind"),
		Limit:    intParam(query, "limit", 50),
		Offset:   intParam(query, "offset", 0),
	})
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, map[string]any{
		"items":  runs,
		"total":  total,
		"limit":  intParam(query, "limit", 50),
		"offset": intParam(query, "offset", 0),
	})
}

func (h *Handler) listItems(w http.ResponseWriter, r *http.Request) {
	query := r.URL.Query()
	filter := repository.ItemFilter{
		SourceID: query.Get("source_id"),
		Query:    query.Get("q"),
		Limit:    intParam(query, "limit", 50),
		Offset:   intParam(query, "offset", 0),
	}
	switch query.Get("removed") {
	case "true":
		removed := true
		filter.Removed = &removed
	case "false":
		removed := false
		filter.Removed = &removed
	}
	items, total, err := h.collector.ListItems(r.Context(), filter)
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, map[string]any{
		"items":  items,
		"total":  total,
		"limit":  intParam(query, "limit", 50),
		"offset": intParam(query, "offset", 0),
	})
}

// jobDetail renders a job with its JSON payload and result inlined. Payload
// and result are opaque to the API; the collector owns their shape.
func jobDetail(job *domain.Job) map[string]any {
	out := map[string]any{
		"id":           job.ID,
		"created_at":   job.CreatedAt,
		"updated_at":   job.UpdatedAt,
		"source_id":    job.SourceID,
		"kind":         job.Kind,
		"remote_id":    job.RemoteID,
		"status":       job.Status,
		"attempts":     job.Attempts,
		"max_attempts": job.MaxAttempts,
		"run_after":    job.RunAfter,
		"last_error":   job.LastError,
	}
	if job.Payload != "" {
		out["payload"] = json.RawMessage(job.Payload)
	}
	if job.Result != "" {
		out["result"] = json.RawMessage(job.Result)
	}
	return out
}

func intParam(values url.Values, key string, fallback int) int {
	parsed, err := strconv.Atoi(values.Get(key))
	if err != nil {
		return fallback
	}
	return parsed
}
