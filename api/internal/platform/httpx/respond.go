package httpx

import (
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5/middleware"

	"github.com/pagefau1t/speedvideo/api/internal/platform/apperr"
)

const maxBodyBytes = 1 << 20 // 1 MiB

// ErrorBody is the stable error shape returned by every endpoint.
type ErrorBody struct {
	Code      string `json:"code"`
	Message   string `json:"message"`
	RequestID string `json:"request_id,omitempty"`
}

// ErrorEnvelope wraps API errors so clients can branch on `error.code`.
type ErrorEnvelope struct {
	Error ErrorBody `json:"error"`
}

// WriteJSON writes v as JSON with the given status and no-store caching.
func WriteJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.Header().Set("Cache-Control", "no-store")
	w.WriteHeader(status)
	if v == nil {
		return
	}
	if err := json.NewEncoder(w).Encode(v); err != nil {
		// The response is already committed; logging is the only safe action.
		slog.Default().Error("encode response", slog.String("error", err.Error()))
	}
}

// WriteError translates an application error into the HTTP error contract.
func WriteError(w http.ResponseWriter, r *http.Request, log *slog.Logger, err error) {
	status, code := http.StatusInternalServerError, "internal_error"
	message := "internal server error"

	var appErr *apperr.Error
	if errors.As(err, &appErr) {
		message = appErr.Message
		switch appErr.Kind {
		case apperr.KindValidation:
			status, code = http.StatusUnprocessableEntity, "validation_failed"
		case apperr.KindUnauthorized:
			status, code = http.StatusUnauthorized, "unauthorized"
			w.Header().Set("WWW-Authenticate", `Bearer realm="speedvideo"`)
		case apperr.KindForbidden:
			status, code = http.StatusForbidden, "forbidden"
		case apperr.KindNotFound:
			status, code = http.StatusNotFound, "not_found"
		case apperr.KindConflict:
			status, code = http.StatusConflict, "conflict"
		case apperr.KindTooManyRequests:
			status, code = http.StatusTooManyRequests, "rate_limited"
		}
	}

	if status >= http.StatusInternalServerError {
		log.Error("request failed",
			slog.String("error", err.Error()),
			slog.String("method", r.Method),
			slog.String("path", r.URL.Path),
			slog.String("request_id", middleware.GetReqID(r.Context())),
		)
	} else {
		log.Debug("request rejected",
			slog.String("error", err.Error()),
			slog.String("method", r.Method),
			slog.String("path", r.URL.Path),
			slog.String("request_id", middleware.GetReqID(r.Context())),
		)
	}

	WriteJSON(w, status, ErrorEnvelope{Error: ErrorBody{
		Code:      code,
		Message:   message,
		RequestID: middleware.GetReqID(r.Context()),
	}})
}

// DecodeJSON decodes a single JSON object from the request body with a strict
// size limit and rejects trailing documents.
func DecodeJSON(w http.ResponseWriter, r *http.Request, dst any) error {
	r.Body = http.MaxBytesReader(w, r.Body, maxBodyBytes)
	dec := json.NewDecoder(r.Body)
	if err := dec.Decode(dst); err != nil {
		if errors.Is(err, io.EOF) {
			return apperr.New(apperr.KindValidation, "request body is required")
		}
		var maxErr *http.MaxBytesError
		if errors.As(err, &maxErr) {
			return apperr.New(apperr.KindValidation, "request body is too large")
		}
		return apperr.New(apperr.KindValidation, "request body must be valid JSON")
	}
	if err := dec.Decode(&struct{}{}); !errors.Is(err, io.EOF) {
		return apperr.New(apperr.KindValidation, "request body must contain a single JSON object")
	}
	return nil
}
