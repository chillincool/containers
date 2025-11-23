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
	@if [ -z "$(VERSION)" ]; then echo "WARNING: VERSION not specified, build may fail if app requires it"; fi
	docker build -t $(IMAGE) \
		--build-arg VERSION=$(VERSION) \
		--build-arg VENDOR=$(VENDOR) \
		-f apps/$(APP)/Dockerfile apps/$(APP)
	@echo "Image built: $(IMAGE)"

buildx:
	@echo "Building multi-arch image for $(APP) (linux/amd64,linux/arm64)..."
	@if [ -z "$(VERSION)" ]; then echo "WARNING: VERSION not specified, build may fail if app requires it"; fi
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--build-arg VERSION=$(VERSION) \
		--build-arg VENDOR=$(VENDOR) \
		-t $(IMAGE) \
		-f apps/$(APP)/Dockerfile \
		apps/$(APP) \
		--load
	@echo "Image loaded: $(IMAGE)"

test:
	@echo "Running tests for apps/$(APP)..."
	@if [ -z "$(TEST_IMAGE)" ]; then \
		echo "  (no TEST_IMAGE set; using test defaults)"; \
	else \
		echo "  Using TEST_IMAGE=$(TEST_IMAGE)"; \
	fi
	@go mod tidy
	TEST_IMAGE=$(TEST_IMAGE) go test -v ./apps/$(APP)/...

debug-run:
	@echo "Starting debug shell in $(IMAGE)..."
	docker run --rm -it --entrypoint /bin/sh $(IMAGE)

.DEFAULT_GOAL := help
