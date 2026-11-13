// Package httpapi is the library module's HTTP transport.
package httpapi

import (
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/pagefau1t/speedvideo/api/internal/modules/library/service"
	"github.com/pagefau1t/speedvideo/api/internal/platform/httpx"
)

// Handler exposes watch list and playback progress endpoints.
type Handler struct {
	library *service.Service
	log     *slog.Logger
}

// New builds the library HTTP transport.
func New(library *service.Service, log *slog.Logger) *Handler {
	return &Handler{library: library, log: log.With(slog.String("module", "library"))}
}

// Routes mounts library endpoints on an authenticated, profile-scoped group.
func (h *Handler) Routes(r chi.Router) {
	r.Get("/watchlist", h.list)
	r.Put("/watchlist/{titleID}", h.add)
	r.Delete("/watchlist/{titleID}", h.remove)
	r.Put("/progress/{titleID}", h.saveProgress)
}

type progressRequest struct {
	EpisodeID       string `json:"episode_id"       validate:"omitempty,uuid"`
	PositionSeconds int    `json:"position_seconds" validate:"min=0"`
	DurationSeconds int    `json:"duration_seconds" validate:"required,min=1"`
}

func (h *Handler) list(w http.ResponseWriter, r *http.Request) {
	actor := httpx.MustActor(r.Context())
	cards, err := h.library.Watchlist(r.Context(), actor.ProfileID, actor.IsKids)
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, map[string]any{"items": cards})
}

func (h *Handler) add(w http.ResponseWriter, r *http.Request) {
	actor := httpx.MustActor(r.Context())
	if err := h.library.Add(r.Context(), actor.ProfileID, chi.URLParam(r, "titleID"), actor.IsKids); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *Handler) remove(w http.ResponseWriter, r *http.Request) {
	actor := httpx.MustActor(r.Context())
	if err := h.library.Remove(r.Context(), actor.ProfileID, chi.URLParam(r, "titleID")); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *Handler) saveProgress(w http.ResponseWriter, r *http.Request) {
	actor := httpx.MustActor(r.Context())
	var req progressRequest
	if err := httpx.DecodeJSON(w, r, &req); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	if err := httpx.Validate(req); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	err := h.library.SaveProgress(r.Context(), actor.ProfileID, chi.URLParam(r, "titleID"),
		req.EpisodeID, req.PositionSeconds, req.DurationSeconds)
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}
