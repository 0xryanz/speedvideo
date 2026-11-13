// Package apperr defines transport-agnostic application errors. Service and
// repository layers return these errors; HTTP handlers translate them into
// status codes and problem payloads.
package apperr

import (
	"errors"
	"fmt"
)

// Kind classifies an application error so transports can map it consistently.
type Kind uint8

const (
	KindUnknown Kind = iota
	KindValidation
	KindUnauthorized
	KindForbidden
	KindNotFound
	KindConflict
	KindTooManyRequests
)

// Error is an application error with a user-safe message. Internal causes are
// retained for logging but never serialized to clients.
type Error struct {
	Kind    Kind
	Message string
	cause   error
}

func (e *Error) Error() string {
	if e.cause != nil {
		return fmt.Sprintf("%s: %v", e.Message, e.cause)
	}
	return e.Message
}

func (e *Error) Unwrap() error { return e.cause }

// New builds an application error.
func New(kind Kind, format string, args ...any) *Error {
	return &Error{Kind: kind, Message: fmt.Sprintf(format, args...)}
}

// Wrap builds an application error that keeps the underlying cause.
func Wrap(kind Kind, cause error, format string, args ...any) *Error {
	return &Error{Kind: kind, Message: fmt.Sprintf(format, args...), cause: cause}
}

// IsKind reports whether err (or an error it wraps) has the given kind.
func IsKind(err error, kind Kind) bool {
	var target *Error
	return errors.As(err, &target) && target.Kind == kind
}

// PublicMessage returns the user-safe message for transport layers.
func PublicMessage(err error) string {
	var target *Error
	if errors.As(err, &target) {
		return target.Message
	}
	return "internal server error"
}
