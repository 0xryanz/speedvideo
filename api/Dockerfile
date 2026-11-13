# syntax=docker/dockerfile:1.7

FROM golang:1.26-alpine AS build
WORKDIR /src
RUN apk add --no-cache ca-certificates
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/api ./cmd/api

FROM gcr.io/distroless/static-debian12:nonroot
WORKDIR /app
COPY --from=build /out/api /app/api
ENV HTTP_ADDR=:8080
EXPOSE 8080
USER nonroot:nonroot
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD ["/app/api", "healthcheck"]
ENTRYPOINT ["/app/api"]
