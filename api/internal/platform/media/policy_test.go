package media

import (
	"context"
	"fmt"
	"testing"

	"github.com/stretchr/testify/require"
)

type stubSourceHosts struct {
	bySource map[string][]string
}

func (s stubSourceHosts) MediaHosts(_ context.Context, sourceID string) ([]string, error) {
	hosts, ok := s.bySource[sourceID]
	if !ok {
		return nil, fmt.Errorf("unknown source %q", sourceID)
	}
	return hosts, nil
}

func TestPolicyRejectsHostsOutsideTheStaticAllowlist(t *testing.T) {
	policy := NewPolicy(NewAllowlist([]string{"media.example.com"}), nil)
	require.NoError(t, policy.Check(context.Background(), "https://media.example.com/a.m3u8", ""))
	require.Error(t, policy.Check(context.Background(), "https://cdn.other.com/a.m3u8", ""))
	require.Error(t, policy.Check(context.Background(), "http://media.example.com/a.m3u8", ""))
}

func TestPolicyUsesDeclaredSourceHostsForImportedTitles(t *testing.T) {
	policy := NewPolicy(
		NewAllowlist([]string{"media.example.com"}),
		stubSourceHosts{bySource: map[string][]string{"src-1": {"cdn.provider.example"}}},
	)
	require.NoError(
		t,
		policy.Check(context.Background(), "https://cdn.provider.example/a.m3u8", "src-1"),
	)
	require.Error(
		t,
		policy.Check(context.Background(), "https://media.example.com/a.m3u8", "src-1"),
	)
	require.Error(
		t,
		policy.Check(context.Background(), "https://cdn.provider.example/a.m3u8", "src-2"),
	)
}

func TestPolicyRejectsImportedTitlesWithoutASourceRegistry(t *testing.T) {
	policy := NewPolicy(NewAllowlist([]string{"media.example.com"}), nil)
	require.Error(
		t,
		policy.Check(context.Background(), "https://cdn.provider.example/a.m3u8", "src-1"),
	)
}
