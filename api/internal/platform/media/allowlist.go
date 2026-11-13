package media

import (
	"fmt"
	"net/url"
	"strings"
)

// Allowlist restricts signed media URLs to trusted HTTPS origins. Every URL is
// checked both when a grant is signed and when it is redeemed, so a leaked
// signing key still cannot point clients at arbitrary hosts.
type Allowlist struct {
	hosts map[string]struct{}
}

// NewAllowlist normalises and stores the permitted hostnames.
func NewAllowlist(hosts []string) *Allowlist {
	list := &Allowlist{hosts: make(map[string]struct{}, len(hosts))}
	for _, host := range hosts {
		host = strings.ToLower(strings.TrimSpace(host))
		if host != "" {
			list.hosts[host] = struct{}{}
		}
	}
	return list
}

// Check validates the URL scheme and hostname.
func (a *Allowlist) Check(raw string) error {
	parsed, err := url.Parse(raw)
	if err != nil {
		return fmt.Errorf("parse media url: %w", err)
	}
	if parsed.Scheme != "https" {
		return fmt.Errorf("media scheme %q is not https", parsed.Scheme)
	}
	if _, ok := a.hosts[strings.ToLower(parsed.Hostname())]; !ok {
		return fmt.Errorf("media host %q is not allow-listed", parsed.Hostname())
	}
	return nil
}
