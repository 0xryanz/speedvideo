// Package httpapi is the download module's HTTP transport.
package httpapi

import (
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/pagefau1t/speedvideo/api/internal/modules/download/service"
	"github.com/pagefau1t/speedvideo/api/internal/platform/httpx"
)

// Handler exposes signed download endpoints.
type Handler struct {
	downloads *service.Service
	log       *slog.Logger
}

// New builds the download HTTP transport.
func New(downloads *service.Service, log *slog.Logger) *Handler {
	return &Handler{downloads: downloads, log: log.With(slog.String("module", "download"))}
}

// ProtectedRoutes creates download grants. The caller applies auth and profile
// middleware.
func (h *Handler) ProtectedRoutes(r chi.Router) {
	r.Get("/downloads/{titleID}", h.create)
}

// PublicRoutes redirects a signed grant to the offline rendition. Native
// download clients do not send app headers, so the HMAC token authorises it.
func (h *Handler) PublicRoutes(r chi.Router) {
	r.Get("/downloads/file/{token}", h.file)
}

func (h *Handler) create(w http.ResponseWriter, r *http.Request) {
	actor := httpx.MustActor(r.Context())
	download, err := h.downloads.Create(r.Context(),
		chi.URLParam(r, "titleID"),
		r.URL.Query().Get("episode_id"),
		actor.ProfileID,
		actor.IsKids,
	)
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, download)
}

func (h *Handler) file(w http.ResponseWriter, r *http.Request) {
	target, err := h.downloads.Resolve(chi.URLParam(r, "token"))
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	w.Header().Set("Cache-Control", "no-store")
	w.Header().Set("Referrer-Policy", "no-referrer")
	http.Redirect(w, r, target, http.StatusFound)
}
