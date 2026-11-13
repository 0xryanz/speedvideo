// Package httpapi is the catalog module's HTTP transport.
package httpapi

import (
	"log/slog"
	"net/http"
	"strconv"
	"strings"

	"github.com/go-chi/chi/v5"

	"github.com/pagefau1t/speedvideo/api/internal/modules/catalog/service"
	"github.com/pagefau1t/speedvideo/api/internal/platform/httpx"
)

// Handler exposes catalog endpoints.
type Handler struct {
	catalog *service.Service
	log     *slog.Logger
}

// New builds the catalog HTTP transport.
func New(catalog *service.Service, log *slog.Logger) *Handler {
	return &Handler{catalog: catalog, log: log.With(slog.String("module", "catalog"))}
}

// Routes mounts catalog endpoints. The caller applies auth and profile
// middleware to the group.
func (h *Handler) Routes(r chi.Router) {
	r.Get("/genres", h.genres)
	r.Get("/titles", h.browse)
	r.Get("/titles/{titleID}", h.detail)
	r.Get("/titles/{titleID}/similar", h.similar)
	r.Get("/search", h.search)
}

func (h *Handler) genres(w http.ResponseWriter, r *http.Request) {
	genres, err := h.catalog.Genres(r.Context())
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, map[string]any{"genres": genres})
}

func (h *Handler) browse(w http.ResponseWriter, r *http.Request) {
	actor, _ := httpx.ActorFrom(r.Context())
	query := r.URL.Query()
	browse := service.BrowseFilter{
		Kind:     strings.TrimSpace(query.Get("kind")),
		Genre:    strings.TrimSpace(query.Get("genre")),
		Sort:     strings.TrimSpace(query.Get("sort")),
		Page:     atoiDefault(query.Get("page"), 1),
		PageSize: atoiDefault(query.Get("page_size"), 20),
	}
	result, err := h.catalog.Browse(r.Context(), browse, actor.IsKids)
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, result)
}

func (h *Handler) detail(w http.ResponseWriter, r *http.Request) {
	actor, _ := httpx.ActorFrom(r.Context())
	detail, err := h.catalog.Detail(
		r.Context(),
		chi.URLParam(r, "titleID"),
		actor.ProfileID,
		actor.IsKids,
	)
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, detail)
}

func (h *Handler) similar(w http.ResponseWriter, r *http.Request) {
	actor, _ := httpx.ActorFrom(r.Context())
	cards, err := h.catalog.Similar(r.Context(), chi.URLParam(r, "titleID"), actor.IsKids, 12)
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, map[string]any{"items": cards})
}

func (h *Handler) search(w http.ResponseWriter, r *http.Request) {
	actor, _ := httpx.ActorFrom(r.Context())
	query := strings.TrimSpace(r.URL.Query().Get("q"))
	kind := strings.TrimSpace(r.URL.Query().Get("kind"))
	cards, err := h.catalog.Search(r.Context(), query, kind, actor.IsKids, 30)
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, map[string]any{"items": cards, "query": query})
}

func atoiDefault(raw string, fallback int) int {
	if raw == "" {
		return fallback
	}
	value, err := strconv.Atoi(raw)
	if err != nil {
		return fallback
	}
	return value
}
