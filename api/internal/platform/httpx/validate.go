package httpx

import (
	"fmt"
	"reflect"
	"strings"

	"github.com/go-playground/validator/v10"

	"github.com/pagefau1t/speedvideo/api/internal/platform/apperr"
)

var validate = validator.New(validator.WithRequiredStructEnabled())

func init() {
	validate.RegisterTagNameFunc(func(field reflect.StructField) string {
		name := strings.SplitN(field.Tag.Get("json"), ",", 2)[0]
		if name == "" || name == "-" {
			return field.Name
		}
		return name
	})
}

// Validate checks a request DTO using `validate` struct tags and converts
// field errors into a single client-safe validation error.
func Validate(dst any) error {
	err := validate.Struct(dst)
	if err == nil {
		return nil
	}
	var fieldErrs validator.ValidationErrors
	if !asValidationErrors(err, &fieldErrs) {
		return apperr.New(apperr.KindValidation, "invalid request")
	}
	parts := make([]string, 0, len(fieldErrs))
	for _, fieldErr := range fieldErrs {
		parts = append(parts, fmt.Sprintf("%s: %s", fieldErr.Field(), validationMessage(fieldErr)))
	}
	return apperr.New(apperr.KindValidation, "invalid request: %s", strings.Join(parts, "; "))
}

func asValidationErrors(err error, target *validator.ValidationErrors) bool {
	if errs, ok := err.(validator.ValidationErrors); ok {
		*target = errs
		return true
	}
	return false
}

func validationMessage(err validator.FieldError) string {
	switch err.Tag() {
	case "required":
		return "is required"
	case "email":
		return "must be a valid email address"
	case "min":
		return "must be at least " + err.Param() + " characters"
	case "max":
		return "must be at most " + err.Param() + " characters"
	case "oneof":
		return "must be one of: " + err.Param()
	case "uuid":
		return "must be a valid identifier"
	case "url":
		return "must be a valid URL"
	default:
		return "is invalid"
	}
}
