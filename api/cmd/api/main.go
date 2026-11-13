// Command api runs the SpeedVideo HTTP API.
package main

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/pagefau1t/speedvideo/api/internal/app"
	"github.com/pagefau1t/speedvideo/api/internal/platform/config"
	"github.com/pagefau1t/speedvideo/api/internal/platform/logger"
)

func main() {
	if len(os.Args) > 1 && os.Args[1] == "healthcheck" {
		runHealthcheck()
		return
	}

	cfg, err := config.Load()
	if err != nil {
		logger.Fatal(slog.Default(), "invalid configuration", err)
	}
	log := logger.New(cfg)
	slog.SetDefault(log)

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	application, err := app.New(ctx, cfg, log)
	if err != nil {
		logger.Fatal(log, "startup failed", err)
	}
	defer func() {
		if err := application.Close(); err != nil {
			log.Error("close application", slog.String("error", err.Error()))
		}
	}()

	server := &http.Server{
		Addr:              cfg.HTTPAddr,
		Handler:           application.Handler(),
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       cfg.ReadTimeout,
		WriteTimeout:      cfg.WriteTimeout,
		IdleTimeout:       cfg.IdleTimeout,
		MaxHeaderBytes:    1 << 20,
	}

	serverErr := make(chan error, 1)
	go func() {
		log.Info("http server listening",
			slog.String("addr", cfg.HTTPAddr),
			slog.String("env", cfg.Environment),
			slog.String("public_base_url", cfg.PublicBaseURL),
		)
		if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			serverErr <- err
		}
	}()

	select {
	case err := <-serverErr:
		logger.Fatal(log, "http server failed", err)
	case <-ctx.Done():
		log.Info("shutdown signal received")
	}

	shutdownCtx, cancel := context.WithTimeout(context.Background(), cfg.ShutdownTimeout)
	defer cancel()
	if err := server.Shutdown(shutdownCtx); err != nil {
		log.Error("graceful shutdown failed", slog.String("error", err.Error()))
		_ = server.Close()
	}
	log.Info("http server stopped")
}

// runHealthcheck lets the distroless image expose a container healthcheck
// without shipping curl or wget.
func runHealthcheck() {
	target := os.Getenv("HEALTHCHECK_URL")
	if target == "" {
		target = "http://127.0.0.1:8080/healthz"
	}
	client := &http.Client{Timeout: 3 * time.Second}
	response, err := client.Get(target)
	if err != nil {
		os.Exit(1)
	}
	defer response.Body.Close()
	if response.StatusCode != http.StatusOK {
		os.Exit(1)
	}
}
