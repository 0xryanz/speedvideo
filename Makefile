SHELL := /bin/sh
COMPOSE := docker compose
LOCAL_DB := postgres://speedvideo:speedvideo-local-only@localhost:5433/speedvideo?sslmode=disable

.PHONY: help up down logs db migrate api app collector collector-once admin test test-api test-collector test-admin test-app lint fmt clean

help:
	@echo "up            start Postgres + API with Docker Compose"
	@echo "db            start only Postgres (port 5433)"
	@echo "api           run the API locally against the compose database"
	@echo "migrate       apply database migrations"
	@echo "app           run the Flutter app on macOS against localhost:8080"
	@echo "collector     run the collector against the compose database"
	@echo "admin         run the operations console (Vite dev server)"
	@echo "collector-once run one full scan of every enabled source and exit"
	@echo "test          api + collector + admin + Flutter tests"
	@echo "lint          go vet + flutter analyze"

up:
	$(COMPOSE) up --build

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f api

db:
	$(COMPOSE) up -d db

migrate:
	cd api && DATABASE_URL="$(LOCAL_DB)" go run ./cmd/migrate

api:
	cd api && DATABASE_URL="$(LOCAL_DB)" go run ./cmd/api

app:
	cd app && flutter run -d macos --dart-define=API_BASE_URL=http://localhost:8080

collector:
	cd collector && DATABASE_URL="$(LOCAL_DB)" go run ./cmd/collector

admin:
	cd admin && npm run dev

collector-once:
	cd collector && DATABASE_URL="$(LOCAL_DB)" COLLECTOR_ONCE=true go run ./cmd/collector

test: test-api test-collector test-admin test-app

test-api:
	cd api && go test ./...

test-collector:
	cd collector && go test ./...

test-admin:
	cd admin && npm run test

test-app:
	cd app && flutter test

lint:
	cd api && go vet ./...
	cd collector && go vet ./...
	cd admin && npm run lint
	cd app && flutter analyze

fmt:
	cd api && gofmt -w cmd internal && golines -w --max-len=100 .
	cd collector && gofmt -w cmd internal && golines -w --max-len=100 .
	cd admin && npm run format
	cd app && dart format lib test

clean:
	$(COMPOSE) down -v
	rm -rf app/build api/tmp
