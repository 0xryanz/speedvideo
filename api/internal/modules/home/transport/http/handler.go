// Package httpapi is the home module's HTTP transport.
package httpapi

import (
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/pagefau1t/speedvideo/api/internal/modules/home/service"
	"github.com/pagefau1t/speedvideo/api/internal/platform/httpx"
)

// Handler exposes the personalised home feed.
type Handler struct {
	home *service.Service
	log  *slog.Logger
}

// New builds the home HTTP transport.
func New(home *service.Service, log *slog.Logger) *Handler {
	return &Handler{home: home, log: log.With(slog.String("module", "home"))}
}

// Routes mounts the home endpoint on an authenticated, profile-scoped group.
func (h *Handler) Routes(r chi.Router) {
	r.Get("/home", h.get)
}

func (h *Handler) get(w http.ResponseWriter, r *http.Request) {
	actor, _ := httpx.ActorFrom(r.Context())
	feed, err := h.home.Build(r.Context(), actor.ProfileID, actor.IsKids)
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, feed)
}
