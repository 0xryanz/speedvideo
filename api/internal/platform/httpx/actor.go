package httpx

import (
	"context"
	"errors"
)

// Actor is the authenticated caller derived from a verified access token.
type Actor struct {
	UserID    string
	ProfileID string
	IsKids    bool
}

type actorKey struct{}

// WithActor stores the authenticated actor in the request context.
func WithActor(ctx context.Context, actor Actor) context.Context {
	return context.WithValue(ctx, actorKey{}, actor)
}

// ActorFrom returns the authenticated actor, if any.
func ActorFrom(ctx context.Context) (Actor, bool) {
	actor, ok := ctx.Value(actorKey{}).(Actor)
	return actor, ok
}

// MustActor is reserved for handlers mounted behind RequireProfile, where an
// actor is guaranteed to exist. It panics only on programmer error.
func MustActor(ctx context.Context) Actor {
	actor, ok := ActorFrom(ctx)
	if !ok {
		panic("httpapi: handler requires an authenticated actor")
	}
	return actor
}

// ErrMissingActor is returned when a handler that requires a profile is called
// without one.
var ErrMissingActor = errors.New("missing authenticated actor")
