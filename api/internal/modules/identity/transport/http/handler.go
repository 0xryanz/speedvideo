package httpapi

import (
	"log/slog"
	"net"
	"net/http"
	"strings"

	"github.com/go-chi/chi/v5"

	"github.com/pagefau1t/speedvideo/api/internal/modules/identity/service"
	"github.com/pagefau1t/speedvideo/api/internal/platform/httpx"
)

// Handler exposes identity HTTP endpoints.
type Handler struct {
	auth     *service.AuthService
	profiles *service.ProfileService
	log      *slog.Logger
}

// New builds the identity HTTP transport.
func New(auth *service.AuthService, profiles *service.ProfileService, log *slog.Logger) *Handler {
	return &Handler{
		auth:     auth,
		profiles: profiles,
		log:      log.With(slog.String("module", "identity")),
	}
}

// PublicRoutes registers unauthenticated auth endpoints.
func (h *Handler) PublicRoutes(r chi.Router) {
	r.Post("/auth/register", h.register)
	r.Post("/auth/login", h.login)
	r.Post("/auth/refresh", h.refresh)
	r.Post("/auth/logout", h.logout)
}

// ProtectedRoutes registers account-scoped endpoints.
func (h *Handler) ProtectedRoutes(r chi.Router) {
	r.Get("/me", h.me)
	r.Get("/profiles", h.listProfiles)
	r.Post("/profiles", h.createProfile)
	r.Patch("/profiles/{profileID}", h.updateProfile)
	r.Delete("/profiles/{profileID}", h.deleteProfile)
	r.Post("/profiles/{profileID}/select", h.selectProfile)
}

func (h *Handler) register(w http.ResponseWriter, r *http.Request) {
	var req registerRequest
	if err := httpx.DecodeJSON(w, r, &req); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	if err := httpx.Validate(req); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	session, err := h.auth.Register(
		r.Context(),
		req.Email,
		req.Password,
		req.DisplayName,
		clientMeta(r),
	)
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusCreated, toSession(session))
}

func (h *Handler) login(w http.ResponseWriter, r *http.Request) {
	var req loginRequest
	if err := httpx.DecodeJSON(w, r, &req); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	if err := httpx.Validate(req); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	session, err := h.auth.Login(r.Context(), req.Email, req.Password, clientMeta(r))
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, toSession(session))
}

func (h *Handler) refresh(w http.ResponseWriter, r *http.Request) {
	var req refreshRequest
	if err := httpx.DecodeJSON(w, r, &req); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	if err := httpx.Validate(req); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	session, err := h.auth.Refresh(r.Context(), req.RefreshToken, clientMeta(r))
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, toSession(session))
}

func (h *Handler) logout(w http.ResponseWriter, r *http.Request) {
	var req refreshRequest
	if err := httpx.DecodeJSON(w, r, &req); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	if err := h.auth.Logout(r.Context(), req.RefreshToken); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *Handler) me(w http.ResponseWriter, r *http.Request) {
	actor := httpx.MustActor(r.Context())
	user, err := h.auth.User(r.Context(), actor.UserID)
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	profiles, err := h.profiles.List(r.Context(), actor.UserID)
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, meResponse{
		User:            toUser(user),
		Profiles:        toProfiles(profiles),
		ActiveProfileID: actor.ProfileID,
	})
}

func (h *Handler) listProfiles(w http.ResponseWriter, r *http.Request) {
	actor := httpx.MustActor(r.Context())
	profiles, err := h.profiles.List(r.Context(), actor.UserID)
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, map[string]any{"profiles": toProfiles(profiles)})
}

func (h *Handler) createProfile(w http.ResponseWriter, r *http.Request) {
	actor := httpx.MustActor(r.Context())
	var req createProfileRequest
	if err := httpx.DecodeJSON(w, r, &req); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	if err := httpx.Validate(req); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	profile, err := h.profiles.Create(r.Context(), actor.UserID, service.CreateProfileInput{
		Name:        req.Name,
		IsKids:      req.IsKids,
		AvatarColor: req.AvatarColor,
		Language:    req.Language,
	})
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusCreated, toProfile(*profile))
}

func (h *Handler) updateProfile(w http.ResponseWriter, r *http.Request) {
	actor := httpx.MustActor(r.Context())
	var req updateProfileRequest
	if err := httpx.DecodeJSON(w, r, &req); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	if err := httpx.Validate(req); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	profile, err := h.profiles.Update(
		r.Context(),
		actor.UserID,
		chi.URLParam(r, "profileID"),
		service.UpdateProfileInput{
			Name:        req.Name,
			IsKids:      req.IsKids,
			AvatarColor: req.AvatarColor,
			Language:    req.Language,
		},
	)
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, toProfile(*profile))
}

func (h *Handler) deleteProfile(w http.ResponseWriter, r *http.Request) {
	actor := httpx.MustActor(r.Context())
	if err := h.profiles.Delete(r.Context(), actor.UserID, chi.URLParam(r, "profileID")); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *Handler) selectProfile(w http.ResponseWriter, r *http.Request) {
	actor := httpx.MustActor(r.Context())
	var req selectProfileRequest
	if err := httpx.DecodeJSON(w, r, &req); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	if err := httpx.Validate(req); err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	session, err := h.auth.SelectProfile(
		r.Context(),
		actor.UserID,
		chi.URLParam(r, "profileID"),
		req.RefreshToken,
	)
	if err != nil {
		httpx.WriteError(w, r, h.log, err)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, toSession(session))
}

func clientMeta(r *http.Request) service.ClientMeta {
	return service.ClientMeta{
		UserAgent: r.UserAgent(),
		IP:        clientIP(r),
	}
}

func clientIP(r *http.Request) string {
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err == nil {
		return host
	}
	return strings.TrimSpace(r.RemoteAddr)
}
