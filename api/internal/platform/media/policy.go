package media

import (
	"context"
	"fmt"
	"net/url"
	"strings"
)

// SourceHosts resolves the media hosts declared by an external content
// provider. Implemented by the source module; declared as an interface so the
// media package stays independent of persistence.
type SourceHosts interface {
	MediaHosts(ctx context.Context, sourceID string) ([]string, error)
}

// Policy decides whether a media URL may be handed to a client.
//
// Locally hosted titles are restricted to the deployment allowlist. Imported
// titles are restricted to the hosts declared by their provider, so retiring a
// provider (or removing a host from it) immediately invalidates every
// outstanding grant for that provider's content.
type Policy struct {
	static        *Allowlist
	sources       SourceHosts
	allowInsecure bool
}

// NewPolicy builds a media policy. sources may be nil, in which case imported
// content cannot be signed.
func NewPolicy(static *Allowlist, sources SourceHosts) *Policy {
	return &Policy{static: static, sources: sources}
}

// AllowInsecure permits plain-http media. It exists so local fixtures can be
// exercised in development; config.Load rejects it outside development.
func (p *Policy) AllowInsecure() { p.allowInsecure = true }

// Check validates the URL scheme and host for the given source. An empty
// sourceID means the title is locally hosted and uses the static allowlist.
func (p *Policy) Check(ctx context.Context, raw, sourceID string) error {
	parsed, err := url.Parse(raw)
	if err != nil {
		return fmt.Errorf("parse media url: %w", err)
	}
	if parsed.Scheme != "https" && !(p.allowInsecure && parsed.Scheme == "http") {
		return fmt.Errorf("media scheme %q is not https", parsed.Scheme)
	}
	if sourceID == "" {
		return p.static.Check(raw)
	}
	if p.sources == nil {
		return fmt.Errorf("no external content source is configured")
	}
	hosts, err := p.sources.MediaHosts(ctx, sourceID)
	if err != nil {
		return err
	}
	host := strings.ToLower(parsed.Hostname())
	for _, allowed := range hosts {
		if strings.ToLower(strings.TrimSpace(allowed)) == host {
			return nil
		}
	}
	return fmt.Errorf("media host %q is not declared by its content source", host)
}
