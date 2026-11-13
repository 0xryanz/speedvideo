package httpx

import (
	"crypto/subtle"
	"net/http"
	"runtime/debug"
	"strconv"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/prometheus/client_golang/prometheus"
	"log/slog"

	"github.com/pagefau1t/speedvideo/api/internal/platform/apperr"
	"github.com/pagefau1t/speedvideo/api/internal/platform/security"
)

// RequestLogger emits one structured access log line per request.
func RequestLogger(log *slog.Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			start := time.Now()
			requestID := middleware.GetReqID(r.Context())
			w.Header().Set("X-Request-Id", requestID)

			rec := &statusRecorder{ResponseWriter: w}
			next.ServeHTTP(rec, r)
			if rec.status == 0 {
				rec.status = http.StatusOK
			}

			attrs := []any{
				slog.String("request_id", requestID),
				slog.String("method", r.Method),
				slog.String("path", r.URL.Path),
				slog.String("route", routePattern(r)),
				slog.Int("status", rec.status),
				slog.Int("bytes", rec.bytes),
				slog.Float64("duration_ms", float64(time.Since(start).Microseconds())/1000),
				slog.String("remote_addr", r.RemoteAddr),
			}
			if actor, ok := ActorFrom(r.Context()); ok {
				attrs = append(attrs, slog.String("user_id", actor.UserID))
				if actor.ProfileID != "" {
					attrs = append(attrs, slog.String("profile_id", actor.ProfileID))
				}
			}
			if rec.status >= http.StatusInternalServerError {
				log.Error("http request", attrs...)
			} else {
				log.Info("http request", attrs...)
			}
		})
	}
}

// Recoverer converts panics into opaque 500 responses and structured logs.
func Recoverer(log *slog.Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			defer func() {
				if rec := recover(); rec != nil {
					if rec == http.ErrAbortHandler {
						panic(rec)
					}
					log.Error("panic recovered",
						slog.Any("panic", rec),
						slog.String("request_id", middleware.GetReqID(r.Context())),
						slog.String("stack", string(debug.Stack())),
					)
					WriteError(w, r, log, apperr.New(apperr.KindUnknown, "internal server error"))
				}
			}()
			next.ServeHTTP(w, r)
		})
	}
}

// SecureHeaders sets conservative defaults for an API and static asset host.
func SecureHeaders(production bool) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("X-Content-Type-Options", "nosniff")
			w.Header().Set("X-Frame-Options", "DENY")
			w.Header().Set("Referrer-Policy", "strict-origin-when-cross-origin")
			w.Header().Set("Cross-Origin-Resource-Policy", "cross-origin")
			if production {
				w.Header().Set("Strict-Transport-Security", "max-age=31536000; includeSubDomains")
			}
			next.ServeHTTP(w, r)
		})
	}
}

// Authenticate verifies the bearer access token and injects the Actor.
func Authenticate(tokens *security.TokenManager) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			raw, ok := bearerToken(r)
			if !ok {
				WriteError(
					w,
					r,
					slog.Default(),
					apperr.New(apperr.KindUnauthorized, "authentication required"),
				)
				return
			}
			claims, err := tokens.Parse(raw)
			if err != nil {
				WriteError(
					w,
					r,
					slog.Default(),
					apperr.New(apperr.KindUnauthorized, "access token is invalid or expired"),
				)
				return
			}
			ctx := WithActor(r.Context(), Actor{
				UserID:    claims.UserID,
				ProfileID: claims.ProfileID,
				IsKids:    claims.IsKids,
			})
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

// OptionalAuthenticate attaches the actor when a bearer token is present and
// valid, and lets anonymous requests through untouched. A present but invalid
// token still returns 401 so clients can refresh an expired access token.
func OptionalAuthenticate(tokens *security.TokenManager) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			raw, ok := bearerToken(r)
			if !ok {
				next.ServeHTTP(w, r)
				return
			}
			claims, err := tokens.Parse(raw)
			if err != nil {
				WriteError(
					w,
					r,
					slog.Default(),
					apperr.New(apperr.KindUnauthorized, "access token is invalid or expired"),
				)
				return
			}
			ctx := WithActor(r.Context(), Actor{
				UserID:    claims.UserID,
				ProfileID: claims.ProfileID,
				IsKids:    claims.IsKids,
			})
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

// RequireProfile rejects account-scoped tokens that have not selected a
// profile. Catalog, library and playback endpoints are all profile-scoped.
func RequireProfile(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		actor, ok := ActorFrom(r.Context())
		if !ok || actor.ProfileID == "" {
			WriteError(
				w,
				r,
				slog.Default(),
				apperr.New(apperr.KindForbidden, "select a profile to continue"),
			)
			return
		}
		next.ServeHTTP(w, r)
	})
}

// RequireAdminToken guards the operations API with a shared bearer secret. The
// token is meant to be held by the admin console's reverse proxy, never by a
// browser: that keeps the management surface server-to-server.
func RequireAdminToken(token string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			provided, ok := bearerToken(r)
			if !ok || subtle.ConstantTimeCompare([]byte(provided), []byte(token)) != 1 {
				WriteJSON(w, http.StatusUnauthorized, ErrorEnvelope{Error: ErrorBody{
					Code:    "unauthorized",
					Message: "admin token required",
				}})
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}

func bearerToken(r *http.Request) (string, bool) {
	header := strings.TrimSpace(r.Header.Get("Authorization"))
	if header == "" {
		return "", false
	}
	scheme, token, ok := strings.Cut(header, " ")
	if !ok || !strings.EqualFold(scheme, "Bearer") {
		return "", false
	}
	token = strings.TrimSpace(token)
	return token, token != ""
}

// Metrics owns the HTTP golden signals exposed at /metrics.
type Metrics struct {
	requests *prometheus.CounterVec
	duration *prometheus.HistogramVec
	inFlight prometheus.Gauge
}

// NewMetrics registers request metrics exactly once at composition time.
func NewMetrics() *Metrics {
	m := &Metrics{
		requests: prometheus.NewCounterVec(prometheus.CounterOpts{
			Namespace: "speedvideo",
			Subsystem: "http",
			Name:      "requests_total",
			Help:      "HTTP requests processed, by route and status.",
		}, []string{"method", "route", "status"}),
		duration: prometheus.NewHistogramVec(prometheus.HistogramOpts{
			Namespace: "speedvideo",
			Subsystem: "http",
			Name:      "request_duration_seconds",
			Help:      "HTTP request latency in seconds.",
			Buckets:   prometheus.DefBuckets,
		}, []string{"method", "route"}),
		inFlight: prometheus.NewGauge(prometheus.GaugeOpts{
			Namespace: "speedvideo",
			Subsystem: "http",
			Name:      "requests_in_flight",
			Help:      "Current number of in-flight HTTP requests.",
		}),
	}
	prometheus.MustRegister(m.requests, m.duration, m.inFlight)
	return m
}

// Instrument records the golden signals. Route patterns (not raw paths) are
// used as labels to keep cardinality bounded.
func (m *Metrics) Instrument(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		m.inFlight.Inc()
		defer m.inFlight.Dec()

		rec := &statusRecorder{ResponseWriter: w}
		next.ServeHTTP(rec, r)
		if rec.status == 0 {
			rec.status = http.StatusOK
		}
		route := routePattern(r)
		if route == "" {
			route = "unmatched"
		}
		m.requests.WithLabelValues(r.Method, route, strconv.Itoa(rec.status)).Inc()
		m.duration.WithLabelValues(r.Method, route).Observe(time.Since(start).Seconds())
	})
}

type statusRecorder struct {
	http.ResponseWriter
	status int
	bytes  int
}

func (r *statusRecorder) WriteHeader(code int) {
	if r.status == 0 {
		r.status = code
	}
	r.ResponseWriter.WriteHeader(code)
}

func (r *statusRecorder) Write(b []byte) (int, error) {
	if r.status == 0 {
		r.status = http.StatusOK
	}
	n, err := r.ResponseWriter.Write(b)
	r.bytes += n
	return n, err
}

// Unwrap keeps http.ResponseController features (flushing, deadlines) working.
func (r *statusRecorder) Unwrap() http.ResponseWriter { return r.ResponseWriter }

func routePattern(r *http.Request) string {
	routeCtx := chi.RouteContext(r.Context())
	if routeCtx == nil {
		return ""
	}
	if pattern := routeCtx.RoutePattern(); pattern != "" {
		return pattern
	}
	return routeCtx.RoutePattern()
}
