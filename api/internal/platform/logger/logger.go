package logger

import (
	"fmt"
	"log/slog"
	"os"
	"strings"

	"github.com/pagefau1t/speedvideo/api/internal/platform/config"
)

// New builds the process-wide structured logger. Production deployments emit
// JSON so log collectors can index fields without parsing.
func New(cfg *config.Config) *slog.Logger {
	level := slog.LevelInfo
	switch strings.ToLower(cfg.LogLevel) {
	case "debug":
		level = slog.LevelDebug
	case "warn":
		level = slog.LevelWarn
	case "error":
		level = slog.LevelError
	}

	opts := &slog.HandlerOptions{
		Level:     level,
		AddSource: level == slog.LevelDebug,
		ReplaceAttr: func(_ []string, attr slog.Attr) slog.Attr {
			if attr.Key == slog.TimeKey {
				attr.Value = slog.StringValue(
					attr.Value.Time().UTC().Format("2006-01-02T15:04:05.000Z07:00"),
				)
			}
			return attr
		},
	}

	var handler slog.Handler
	if cfg.Environment == "development" || !cfg.Production() {
		handler = slog.NewTextHandler(os.Stdout, opts)
	} else {
		handler = slog.NewJSONHandler(os.Stdout, opts)
	}
	return slog.New(handler).With(
		slog.String("service", "speedvideo-api"),
		slog.String("env", cfg.Environment),
	)
}

// Fatal logs an unrecoverable error and exits. It exists for main only.
func Fatal(log *slog.Logger, msg string, err error) {
	log.Error(msg, slog.String("error", fmt.Sprint(err)))
	os.Exit(1)
}
