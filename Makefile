.PHONY: help build-image buildx test debug-run

# App name (required)
APP ?=
IMAGE ?= ghcr.io/chillincool/containers/$(APP):local
REGISTRY ?= ghcr.io/chillincool
VENDOR ?= chillincool
VERSION ?=

help:
	@echo "Local development targets for chillincool/containers"
	@echo ""
	@echo "Usage: make [target] APP=<app> [VERSION=<version>] [VENDOR=<vendor>] [IMAGE=<image>]"
	@echo ""
	@echo "Required:"
	@echo "  APP=<app>        App name (e.g., radarr, sonarr)"
	@echo ""
	@echo "Targets:"
	@echo "  build-image      Build single-arch image locally (fast, no push)"
	@echo "  buildx           Build multi-arch with buildx and load into local Docker"
	@echo "  test             Run go test for app (respects TEST_IMAGE env var)"
	@echo "  debug-run        Start a shell in the built image for debugging"
	@echo "  build-plex       Build Plex using version from apps/plex/VERSION file"
	@echo "  update-plex-version  Fetch latest Plex version and update VERSION file"
	@echo "  build-overseerr  Build Overseerr using version from apps/overseerr/VERSION file"
	@echo "  build-suggestarr Build SuggestArr using version from apps/suggestarr/VERSION file"
	@echo "  build-kometa     Build Kometa using version from apps/kometa/VERSION file"
	@echo "  build-imagemaid  Build ImageMaid using version from apps/imagemaid/VERSION file"
	@echo "  build-huntarr    Build Huntarr using version from apps/huntarr/VERSION file"
	@echo "  build-tautulli   Build Tautulli using version from apps/tautulli/VERSION file"
	@echo "  build-radarr     Build Radarr using version from apps/radarr/VERSION file"
	@echo "  build-sonarr     Build Sonarr using version from apps/sonarr/VERSION file"
	@echo "  build-prowlarr   Build Prowlarr using version from apps/prowlarr/VERSION file"
	@echo "  build-lidarr     Build Lidarr using version from apps/lidarr/VERSION file"
	@echo "  build-decypharr  Build Decypharr using version from apps/decypharr/VERSION file"
	@echo ""
	@echo "Examples:"
	@echo "  make build-image APP=radarr"
	@echo "  make build-image APP=sonarr VERSION=4.0.0"
	@echo "  make test APP=radarr"
	@echo "  TEST_IMAGE=my-image:tag make test APP=radarr"
	@echo "  make debug-run APP=radarr IMAGE=my-image:tag"
	@echo ""
	@echo "Optional variables:"
	@echo "  VERSION          Version to build (optional, app may have default)"
	@echo "  VENDOR (default: chillincool)"
	@echo "  IMAGE (default: ghcr.io/chillincool/containers/\$$(APP):local)"
	@echo "  REGISTRY (default: ghcr.io/chillincool)"
	@echo ""

build-image:
	@echo "Building single-arch image for $(APP)..."
	@if [ -n "$(VERSION)" ]; then \
		echo "  With VERSION=$(VERSION)"; \
		docker build -t $(IMAGE) \
			--build-arg VERSION=$(VERSION) \
			-f apps/$(APP)/Dockerfile apps/$(APP); \
	else \
		docker build -t $(IMAGE) \
			-f apps/$(APP)/Dockerfile apps/$(APP); \
	fi
	@echo "Image built: $(IMAGE)"

buildx:
	@echo "Building multi-arch image for $(APP) (linux/amd64,linux/arm64)..."
	@if [ -n "$(VERSION)" ]; then \
		echo "  With VERSION=$(VERSION)"; \
		docker buildx build \
			--platform linux/amd64,linux/arm64 \
			--build-arg VERSION=$(VERSION) \
			-t $(IMAGE) \
			-f apps/$(APP)/Dockerfile \
			apps/$(APP) \
			--load; \
	else \
		docker buildx build \
			--platform linux/amd64,linux/arm64 \
			-t $(IMAGE) \
			-f apps/$(APP)/Dockerfile \
			apps/$(APP) \
			--load; \
	fi
	@echo "Image loaded: $(IMAGE)"

test:
	@echo "Running tests for apps/$(APP)..."
	@if [ -z "$(TEST_IMAGE)" ]; then \
		echo "  (no TEST_IMAGE set; using test defaults)"; \
	else \
		echo "  Using TEST_IMAGE=$(TEST_IMAGE)"; \
	fi
	@go mod tidy
	TEST_IMAGE=$(TEST_IMAGE) go test -v ./apps/$(APP)

debug-run:
	@echo "Starting debug shell in $(IMAGE)..."
	docker run --rm -it --entrypoint /bin/sh $(IMAGE)

# Plex-specific: build using version from VERSION file
build-plex:
	@if [ ! -f apps/plex/VERSION ]; then \
		echo "Error: apps/plex/VERSION file not found"; \
		exit 1; \
	fi
	@PLEX_VERSION=$$(cat apps/plex/VERSION); \
	echo "Building Plex with version: $$PLEX_VERSION"; \
	$(MAKE) build-image APP=plex VERSION=$$PLEX_VERSION

# Plex-specific: fetch latest version from API and update VERSION file
update-plex-version:
	@echo "Fetching latest Plex version..."
	@PLEX_VERSION=$$(curl -s https://plex.tv/api/downloads/5.json | jq -r '.computer.Linux.version'); \
	echo "Latest version: $$PLEX_VERSION"; \
	echo "$$PLEX_VERSION" > apps/plex/VERSION; \
	echo "Updated apps/plex/VERSION"

# Overseerr-specific: build using version from VERSION file
build-overseerr:
	@if [ ! -f apps/overseerr/VERSION ]; then \
		echo "Error: apps/overseerr/VERSION file not found"; \
		exit 1; \
	fi
	@VERSION=$$(cat apps/overseerr/VERSION); \
	echo "Building Overseerr with version: $$VERSION"; \
	$(MAKE) build-image APP=overseerr VERSION=$$VERSION

# SuggestArr-specific: build using version from VERSION file
build-suggestarr:
	@if [ ! -f apps/suggestarr/VERSION ]; then \
		echo "Error: apps/suggestarr/VERSION file not found"; \
		exit 1; \
	fi
	@VERSION=$$(cat apps/suggestarr/VERSION); \
	echo "Building SuggestArr with version: $$VERSION"; \
	$(MAKE) build-image APP=suggestarr VERSION=$$VERSION

# Kometa-specific: build using version from VERSION file
build-kometa:
	@if [ ! -f apps/kometa/VERSION ]; then \
		echo "Error: apps/kometa/VERSION file not found"; \
		exit 1; \
	fi
	@VERSION=$$(cat apps/kometa/VERSION); \
	echo "Building Kometa with version: $$VERSION"; \
	$(MAKE) build-image APP=kometa VERSION=$$VERSION

# ImageMaid-specific: build using version from VERSION file
build-imagemaid:
	@if [ ! -f apps/imagemaid/VERSION ]; then \
		echo "Error: apps/imagemaid/VERSION file not found"; \
		exit 1; \
	fi
	@VERSION=$$(cat apps/imagemaid/VERSION); \
	echo "Building ImageMaid with version: $$VERSION"; \
	$(MAKE) build-image APP=imagemaid VERSION=$$VERSION

# Huntarr-specific: build using version from VERSION file
build-huntarr:
	@if [ ! -f apps/huntarr/VERSION ]; then \
		echo "Error: apps/huntarr/VERSION file not found"; \
		exit 1; \
	fi
	@VERSION=$$(cat apps/huntarr/VERSION); \
	echo "Building Huntarr with version: $$VERSION"; \
	$(MAKE) build-image APP=huntarr VERSION=$$VERSION

# Tautulli-specific: build using version from VERSION file
build-tautulli:
	@if [ ! -f apps/tautulli/VERSION ]; then \
		echo "Error: apps/tautulli/VERSION file not found"; \
		exit 1; \
	fi
	@VERSION=$$(cat apps/tautulli/VERSION); \
	echo "Building Tautulli with version: $$VERSION"; \
	$(MAKE) build-image APP=tautulli VERSION=$$VERSION

# Radarr-specific: build using version from VERSION file
build-radarr:
	@if [ ! -f apps/radarr/VERSION ]; then \
		echo "Error: apps/radarr/VERSION file not found"; \
		exit 1; \
	fi
	@VERSION=$$(cat apps/radarr/VERSION); \
	echo "Building Radarr with version: $$VERSION"; \
	$(MAKE) build-image APP=radarr VERSION=$$VERSION

# Sonarr-specific: build using version from VERSION file
build-sonarr:
	@if [ ! -f apps/sonarr/VERSION ]; then \
		echo "Error: apps/sonarr/VERSION file not found"; \
		exit 1; \
	fi
	@VERSION=$$(cat apps/sonarr/VERSION); \
	echo "Building Sonarr with version: $$VERSION"; \
	$(MAKE) build-image APP=sonarr VERSION=$$VERSION

# Prowlarr-specific: build using version from VERSION file
build-prowlarr:
	@if [ ! -f apps/prowlarr/VERSION ]; then \
		echo "Error: apps/prowlarr/VERSION file not found"; \
		exit 1; \
	fi
	@VERSION=$$(cat apps/prowlarr/VERSION); \
	echo "Building Prowlarr with version: $$VERSION"; \
	$(MAKE) build-image APP=prowlarr VERSION=$$VERSION

# Lidarr-specific: build using version from VERSION file
build-lidarr:
	@if [ ! -f apps/lidarr/VERSION ]; then \
		echo "Error: apps/lidarr/VERSION file not found"; \
		exit 1; \
	fi
	@VERSION=$$(cat apps/lidarr/VERSION); \
	echo "Building Lidarr with version: $$VERSION"; \
	$(MAKE) build-image APP=lidarr VERSION=$$VERSION

# Decypharr-specific: build using version from VERSION file
build-decypharr:
	@if [ ! -f apps/decypharr/VERSION ]; then \
		echo "Error: apps/decypharr/VERSION file not found"; \
		exit 1; \
	fi
	@VERSION=$$(cat apps/decypharr/VERSION); \
	echo "Building Decypharr with version: $$VERSION"; \
	$(MAKE) build-image APP=decypharr VERSION=$$VERSION

.DEFAULT_GOAL := help
