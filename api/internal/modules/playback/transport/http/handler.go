// Package httpapi is the playback module's HTTP transport.
package httpapi

import (
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/pagefau1t/speedvideo/api/internal/modules/playback/service"
	"github.com/pagefau1t/speedvideo/api/internal/platform/httpx"
)

// Handler exposes signed playback endpoints.
type Handler struct {
	playback *service.Service
	log      *slog.Logger
}

// New builds the playback HTTP transport.
func New(playback *service.Service, log *slog.Logger) *Handler {
	return &Handler{playback: playback, log: log.With(slog.String("module", "playback"))}
}

// GuestRoutes exposes playback session creation to anonymous viewers. The
// caller applies optional auth, so a signed-in profile still receives its
// resume position.
func (h *Handler) GuestRoutes(r chi.Router) {
	r.Get("/playback/{titleID}", h.create)
}

// PublicRoutes exposes the signed manifest redirect. Authorisation is carried
// by the HMAC token because native video players do not send app headers.
func (h *Handler) PublicRoutes(r chi.Router) {
	r.Get("/playback/stream/{token}", h.stream)
}

func (h *Handler) create(w http.ResponseWriter, r *http.Request) {
	actor, _ := httpx.ActorFrom(r.Context())
	playback, err := h.playback.Create(r.Context(),
		chi.URLParam(r, "titleID"),
		r.URL.Query().Get("episode_id"),
		actor.ProfileID,
		actor.IsKids,
	)
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, playback)
}

func (h *Handler) stream(w http.ResponseWriter, r *http.Request) {
	target, err := h.playback.ResolveStream(r.Context(), chi.URLParam(r, "token"))
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	w.Header().Set("Cache-Control", "no-store")
	w.Header().Set("Referrer-Policy", "no-referrer")
	http.Redirect(w, r, target, http.StatusFound)
}
