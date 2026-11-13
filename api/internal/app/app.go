// Package app is the composition root. It is the only place that knows how
// feature modules, platform adapters and HTTP transports fit together.
package app

import (
	"context"
	"fmt"
	"log/slog"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"
	"github.com/go-chi/httprate"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"gorm.io/gorm"

	"github.com/pagefau1t/speedvideo/api/internal/migrations"
	adminhttp "github.com/pagefau1t/speedvideo/api/internal/modules/admin/transport/http"
	catalogrepo "github.com/pagefau1t/speedvideo/api/internal/modules/catalog/repository"
	catalogservice "github.com/pagefau1t/speedvideo/api/internal/modules/catalog/service"
	cataloghttp "github.com/pagefau1t/speedvideo/api/internal/modules/catalog/transport/http"
	collectorrepo "github.com/pagefau1t/speedvideo/api/internal/modules/collector/repository"
	collectorservice "github.com/pagefau1t/speedvideo/api/internal/modules/collector/service"
	downloadservice "github.com/pagefau1t/speedvideo/api/internal/modules/download/service"
	downloadhttp "github.com/pagefau1t/speedvideo/api/internal/modules/download/transport/http"
	homeservice "github.com/pagefau1t/speedvideo/api/internal/modules/home/service"
	homehttp "github.com/pagefau1t/speedvideo/api/internal/modules/home/transport/http"
	identityrepo "github.com/pagefau1t/speedvideo/api/internal/modules/identity/repository"
	identityservice "github.com/pagefau1t/speedvideo/api/internal/modules/identity/service"
	identityhttp "github.com/pagefau1t/speedvideo/api/internal/modules/identity/transport/http"
	libraryrepo "github.com/pagefau1t/speedvideo/api/internal/modules/library/repository"
	libraryservice "github.com/pagefau1t/speedvideo/api/internal/modules/library/service"
	libraryhttp "github.com/pagefau1t/speedvideo/api/internal/modules/library/transport/http"
	playbackservice "github.com/pagefau1t/speedvideo/api/internal/modules/playback/service"
	playbackhttp "github.com/pagefau1t/speedvideo/api/internal/modules/playback/transport/http"
	sourcerepo "github.com/pagefau1t/speedvideo/api/internal/modules/source/repository"
	sourceservice "github.com/pagefau1t/speedvideo/api/internal/modules/source/service"
	"github.com/pagefau1t/speedvideo/api/internal/platform/config"
	"github.com/pagefau1t/speedvideo/api/internal/platform/database"
	"github.com/pagefau1t/speedvideo/api/internal/platform/httpx"
	"github.com/pagefau1t/speedvideo/api/internal/platform/media"
	"github.com/pagefau1t/speedvideo/api/internal/platform/security"
)

// App owns process-scoped dependencies and the HTTP handler.
type App struct {
	config  *config.Config
	log     *slog.Logger
	db      *gorm.DB
	token   *security.TokenManager
	auth    *identityservice.AuthService
	metrics *httpx.Metrics
	handler http.Handler
	cancel  context.CancelFunc
}

// New builds the application. It opens the database, applies migrations and
// optionally installs the starter catalogue before wiring modules together.
func New(ctx context.Context, cfg *config.Config, log *slog.Logger) (*App, error) {
	db, err := database.Open(ctx, cfg, log)
	if err != nil {
		return nil, err
	}

	if cfg.AutoMigrate {
		if err := migrations.Run(db, log); err != nil {
			_ = database.Close(db)
			return nil, err
		}
	}

	tokens := security.NewTokenManager(cfg.JWTSecret, cfg.JWTIssuer, cfg.AccessTokenTTL)
	identityRepos := identityrepo.New(db)
	authService, err := identityservice.NewAuthService(
		identityRepos.Users,
		identityRepos.Profiles,
		identityRepos.RefreshTokens,
		tokens,
		cfg.RefreshTokenTTL,
	)
	if err != nil {
		_ = database.Close(db)
		return nil, fmt.Errorf("build auth service: %w", err)
	}
	profilesService := identityservice.NewProfileService(
		identityRepos.Profiles,
		identityRepos.RefreshTokens,
		cfg.MaxProfiles,
	)

	catalogRepository := catalogrepo.New(db)
	catalogService := catalogservice.New(catalogRepository, nil)
	libraryService := libraryservice.New(libraryrepo.New(db), catalogService)
	catalogService.SetViewer(libraryService)

	// The API is the control plane: it owns the source registry and the
	// collection queue. The collector process is the data plane and only
	// leases queued jobs, so the API never talks to a provider directly.
	sourceRepository := sourcerepo.New(db)
	sourceService := sourceservice.New(sourceRepository, cfg.SourceAllowInsecure)
	collectorService := collectorservice.New(collectorrepo.New(db))
	adminHandler := adminhttp.New(sourceService, collectorService, catalogService, log)
	mediaPolicy := media.NewPolicy(media.NewAllowlist(cfg.AllowedMediaHosts), sourceRepository)
	if cfg.SourceAllowInsecure {
		mediaPolicy.AllowInsecure()
	}

	playbackService := playbackservice.New(
		catalogService,
		libraryService,
		media.NewSigner(cfg.MediaSigningKey),
		cfg.PlaybackTokenTTL,
		cfg.PublicBaseURL,
		mediaPolicy,
	)
	downloadService := downloadservice.New(
		catalogService,
		media.NewSigner(cfg.MediaSigningKey),
		cfg.DownloadTokenTTL,
		cfg.PublicBaseURL,
		cfg.AllowedMediaHosts,
	)
	homeService := homeservice.New(catalogService, libraryService)

	metrics := httpx.NewMetrics()
	router := buildRouter(cfg, log, db, tokens, metrics,
		identityhttp.New(authService, profilesService, log),
		cataloghttp.New(catalogService, log),
		libraryhttp.New(libraryService, log),
		playbackhttp.New(playbackService, log),
		downloadhttp.New(downloadService, log),
		homehttp.New(homeService, log),
		adminHandler,
	)

	maintenanceCtx, cancel := context.WithCancel(context.Background())
	go runRefreshTokenCleanup(maintenanceCtx, authService, log)

	return &App{
		config:  cfg,
		log:     log,
		db:      db,
		token:   tokens,
		auth:    authService,
		metrics: metrics,
		handler: router,
		cancel:  cancel,
	}, nil
}

// Handler returns the composed HTTP handler.
func (a *App) Handler() http.Handler { return a.handler }

// Close stops background work and releases the database pool.
func (a *App) Close() error {
	if a.cancel != nil {
		a.cancel()
	}
	return database.Close(a.db)
}

func buildRouter(
	cfg *config.Config,
	log *slog.Logger,
	db *gorm.DB,
	tokens *security.TokenManager,
	metrics *httpx.Metrics,
	identity *identityhttp.Handler,
	catalog *cataloghttp.Handler,
	library *libraryhttp.Handler,
	playback *playbackhttp.Handler,
	download *downloadhttp.Handler,
	home *homehttp.Handler,
	admin *adminhttp.Handler,
) http.Handler {
	router := chi.NewRouter()
	router.Use(middleware.RequestID)
	if cfg.TrustProxy {
		router.Use(middleware.RealIP)
	}
	router.Use(metrics.Instrument)
	router.Use(httpx.Recoverer(log))
	router.Use(httpx.RequestLogger(log))
	router.Use(httpx.SecureHeaders(cfg.Production()))
	router.Use(cors.Handler(cors.Options{
		AllowedOrigins: cfg.AllowedOrigins,
		AllowedMethods: []string{
			http.MethodGet,
			http.MethodPost,
			http.MethodPut,
			http.MethodPatch,
			http.MethodDelete,
			http.MethodOptions,
		},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type", "X-Request-Id"},
		ExposedHeaders:   []string{"X-Request-Id"},
		AllowCredentials: false,
		MaxAge:           300,
	}))

	router.NotFound(func(w http.ResponseWriter, r *http.Request) {
		httpx.WriteJSON(w, http.StatusNotFound, httpx.ErrorEnvelope{Error: httpx.ErrorBody{
			Code: "not_found", Message: "endpoint not found",
		}})
	})
	router.MethodNotAllowed(func(w http.ResponseWriter, r *http.Request) {
		httpx.WriteJSON(w, http.StatusMethodNotAllowed, httpx.ErrorEnvelope{Error: httpx.ErrorBody{
			Code: "method_not_allowed", Message: "method not allowed",
		}})
	})

	router.Get("/healthz", func(w http.ResponseWriter, r *http.Request) {
		httpx.WriteJSON(w, http.StatusOK, map[string]string{"status": "ok"})
	})
	router.Get("/readyz", readinessHandler(db, log))
	router.Handle("/metrics", promhttp.Handler())

	router.Route("/v1", func(r chi.Router) {
		r.Group(func(public chi.Router) {
			public.Use(httprate.LimitByIP(30, time.Minute))
			identity.PublicRoutes(public)
		})
		r.Group(func(stream chi.Router) {
			stream.Use(httprate.LimitByIP(600, time.Minute))
			playback.PublicRoutes(stream)
			download.PublicRoutes(stream)
		})
		r.Group(func(account chi.Router) {
			account.Use(httpx.Authenticate(tokens))
			account.Use(httprate.LimitByIP(120, time.Minute))
			identity.ProtectedRoutes(account)
		})
		r.Group(func(browse chi.Router) {
			// Browsing and playback are open to guests. A valid bearer token
			// still supplies the profile so personalised rows and resume
			// positions appear for signed-in viewers.
			browse.Use(httpx.OptionalAuthenticate(tokens))
			browse.Use(httprate.LimitByIP(300, time.Minute))
			home.Routes(browse)
			catalog.Routes(browse)
			playback.GuestRoutes(browse)
		})
		r.Group(func(viewer chi.Router) {
			viewer.Use(httpx.Authenticate(tokens))
			viewer.Use(httpx.RequireProfile)
			viewer.Use(httprate.LimitByIP(300, time.Minute))
			library.Routes(viewer)
			download.ProtectedRoutes(viewer)
		})
		if cfg.AdminAPIToken != "" {
			r.Group(func(adminGroup chi.Router) {
				adminGroup.Use(httpx.RequireAdminToken(cfg.AdminAPIToken))
				adminGroup.Use(httprate.LimitByIP(120, time.Minute))
				adminGroup.Route("/admin", admin.Routes)
			})
		}
	})

	return router
}

func readinessHandler(db *gorm.DB, log *slog.Logger) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, cancel := context.WithTimeout(r.Context(), 3*time.Second)
		defer cancel()
		if err := database.Ping(ctx, db); err != nil {
			log.Warn("readiness check failed", slog.String("error", err.Error()))
			httpx.WriteJSON(
				w,
				http.StatusServiceUnavailable,
				map[string]string{"status": "unavailable"},
			)
			return
		}
		httpx.WriteJSON(w, http.StatusOK, map[string]string{"status": "ready"})
	}
}

func runRefreshTokenCleanup(
	ctx context.Context,
	auth *identityservice.AuthService,
	log *slog.Logger,
) {
	ticker := time.NewTicker(6 * time.Hour)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			removed, err := auth.CleanupExpired(ctx, time.Now().UTC().Add(-24*time.Hour))
			if err != nil {
				log.Warn("refresh token cleanup failed", slog.String("error", err.Error()))
				continue
			}
			if removed > 0 {
				log.Info("expired refresh tokens removed", slog.Int64("count", removed))
			}
		}
	}
}
