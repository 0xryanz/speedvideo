# syntax=docker/dockerfile:1.7

FROM golang:1.26-alpine AS build
WORKDIR /src
RUN apk add --no-cache ca-certificates
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/collector ./cmd/collector

FROM gcr.io/distroless/static-debian12:nonroot
WORKDIR /app
COPY --from=build /out/collector /app/collector
USER nonroot:nonroot
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD ["/app/collector", "healthcheck"]
ENTRYPOINT ["/app/collector"]
