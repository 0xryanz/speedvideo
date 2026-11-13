package store

import (
	"testing"

	"github.com/pagefau1t/speedvideo/collector/internal/adapter"
)

func TestWorkKeyGroupsIdenticalWorks(t *testing.T) {
	a := workKeyOf(&adapter.Title{Name: "Fixture Movie", Kind: "movie", Year: 2024})
	b := workKeyOf(&adapter.Title{Name: "fixture  movie", Kind: "movie", Year: 2024})
	if a != b {
		t.Fatalf("expected identical work keys, got %q and %q", a, b)
	}
	c := workKeyOf(&adapter.Title{Name: "Fixture Movie (2024)", Kind: "movie", Year: 2024})
	if a != c {
		t.Fatalf("expected a trailing year to be ignored, got %q and %q", a, c)
	}
	d := workKeyOf(&adapter.Title{Name: "Fixture Movie", Kind: "movie", Year: 2025})
	if a == d {
		t.Fatalf("different years must not collapse: %q", a)
	}
}

func TestWorkKeyKeepsUnknownYearSeparate(t *testing.T) {
	known := workKeyOf(&adapter.Title{Name: "Fixture Show", Kind: "series", Year: 2023})
	unknown := workKeyOf(&adapter.Title{Name: "Fixture Show", Kind: "series"})
	if known == unknown {
		t.Fatalf("a missing year must not be treated as a specific year")
	}
}

func TestWorkKeyIgnoresCaseAndSpacing(t *testing.T) {
	key := workKeyOf(&adapter.Title{Name: "  THE   MATRIX ", Kind: "movie", Year: 1999})
	if key != "the matrix|1999|movie" {
		t.Fatalf("unexpected work key %q", key)
	}
}
