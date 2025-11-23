# AI Agent Instructions for chillincool/containers

This is a private monorepo of OCI container images maintained personally. These instructions help AI agents quickly become productive by understanding the architecture, workflows, and project conventions..

## Architecture Overview

**Repository structure**: Per-application build contexts under `apps/`, each containing:
- `Dockerfile` — Alpine-based image with multi-arch support (amd64, arm64)
- `entrypoint.sh` — Runtime initialization script (template expansion + app startup)
- `config.xml.tmpl` or similar — Gomplate-rendered configuration template
- `container_test.go` — Integration tests using testcontainers-go

**Current app**: Radarr (`apps/radarr/`) — demonstrates the full pattern

**Test infrastructure**: 
- `testhelpers/testhelpers.go` — Shared test helpers for HTTP endpoint testing, command execution, file existence checks
- Uses `testcontainers-go` to start containers during tests with configurable env, wait strategies, and port exposure

**CI/CD pipeline**:
- `.github/workflows/ci.yml` — Main CI workflow triggered on push/PR; detects changed apps, builds images, and runs tests
- `.github/workflows/templates/container-build.yml` — Reusable workflow for multi-arch build + push to GHCR

## Key Files & Patterns

### Dockerfile essentials
- Base: Alpine 3.22 for minimal size
- Build args: `TARGETARCH`, `VENDOR`, `VERSION` (required; mapped from `linux/amd64` → `x64`, `linux/arm64` → `arm64`)
- Downloads upstream binary from upstream endpoint based on VERSION
- Uses `gomplate` for template rendering at runtime
- Healthcheck: HTTP GET to `/ping` on port 7878 (Radarr default)
- Entrypoint: `/usr/bin/catatonit` (init substitute) + `/entrypoint.sh`

### Entrypoint workflow
1. Check if `/config/config.xml` exists; if not, render it from `/config.xml.tmpl` using `gomplate` with env datasource
2. Launch app with `--nobrowser --data=/config` pointing to the config directory
3. Pass through additional CLI args

### Configuration via environment variables
- Template uses Gomplate `{{ getenv "VAR_NAME" | default "fallback" }}` syntax
- Radarr config keys: `RADARR__PORT` (default 7878), `RADARR__API_KEY`, `RADARR__LOG_LEVEL`, etc.
- When modifying templates or tests, preserve environment variable names and defaults for backward compatibility

### Testing pattern
- `container_test.go` imports `testhelpers` package and calls `testhelpers.TestHTTPEndpoint()`
- Tests override image via `TEST_IMAGE` env var; falls back to hardcoded default if unset
- Test waits for listening port + HTTP status code (default 200 on `/`)
- Container startup delays (HEALTHCHECK start-period 45s) are respected via wait strategies

## Development Workflows

### Local development (fastest, zero cost)

Use the `Makefile` for all local development. See `README.LOCAL.md` for comprehensive guide.

**Quick examples:**

```bash
# Build a local single-arch image (fast, ~1-2 min)
make build-image APP=radarr

# Run tests against your local build
TEST_IMAGE=ghcr.io/chillincool/containers/radarr:local make test APP=radarr

# Debug shell in the container
make debug-run APP=radarr IMAGE=ghcr.io/chillincool/containers/radarr:local

# Create a Helm chart skeleton
make helm-scaffold APP=radarr
```

**Recommended workflow**: 
1. Make changes to `apps/radarr/` (Dockerfile, entrypoint, config template)
2. Run `make build-image` to validate locally
3. Run `TEST_IMAGE=...local make test` to ensure tests pass
4. Use `make debug-run` to inspect `/config` and logs if needed
5. Commit and push when satisfied

This avoids paying for CI unless you're confident in the changes.

## CI Workflow Details (ci.yml)

The CI workflow is split into three jobs for cost efficiency:

### 1. Detect Changes (always runs)
- Compares `HEAD` against `origin/main` to find changed `apps/*` directories
- Creates a matrix of changed apps for downstream jobs
- Skips remaining jobs if no apps changed

### 2. PR Validation (on pull_request)
- **Trigger**: Pull requests
- **Build**: Single-arch only (`linux/amd64`) — fast, ~2-3 min
- **Push**: **Does NOT push** to GHCR
- **Test**: Runs `go test` against the built image
- **Cost**: ~$0.007 per PR

This job gives you quick feedback without paying for multi-arch builds.

### 3. Push & Publish (on push to main)
- **Trigger**: Direct push to main branch (typically after PR merge)
- **Build**: Multi-arch (`linux/amd64`, `linux/arm64`) — ~10-15 min
- **Push**: Publishes to GHCR with `:latest` and `:${{ github.sha }}` tags
- **Test**: Runs `go test` against the published image for final validation
- **Cost**: ~$0.035 per push

This is the "full" workflow; only runs when code is merged to main.

**Image tagging**: Built images are tagged with `:latest` (main) and `:${{ github.sha }}` (commit SHA)

**Registry**: GHCR (ghcr.io/chillincool) — authentication via GITHUB_TOKEN

## Project Conventions & Pitfalls

### Do's
- Preserve `TARGETARCH` mapping logic when modifying Dockerfiles (crucial for multi-arch builds)
- Keep `gomplate` and environment variable names stable; they're part of the public configuration surface
- Use `TestHTTPEndpoint()` or `TestCommandSucceeds()` helpers in new tests to maintain CI consistency
- Update HEALTHCHECK port/path in lockstep with template defaults and test expectations
- Keep image naming orthogonal: CI uses fixed namespace (`ghcr.io/chillincool/<app>`); tests override via `TEST_IMAGE`

### Don'ts
- Don't change Dockerfile `HEALTHCHECK` without updating corresponding tests
- Don't remove `gomplate` or rename template variables without updating entrypoint logic
- Don't modify app directory structure (`apps/<app>/`) without updating ci.yml detection or test imports
- Don't assume `:latest` tag is immutable; commit SHA tags enable safe canary deployments

### Common mistakes
- Port mismatch: Template defaults to 7878, but HEALTHCHECK or tests expect different port → test failures
- Missing env var defaults in templates → runtime failures when env is not set
- Uploading images without setting `TEST_IMAGE` before running tests → tests use hardcoded defaults, missing real-world issues

## Future Roadmap: Helm Charts

Plan to maintain Helm charts per app under `helm/<app>/`. Conventions:
- Chart `values.yaml` includes `image.repository`, `image.tag`, `image.pullPolicy`
- CI can update `values.yaml` with `${{ github.sha }}` tag for canary testing
- Keep `image` input (CI build destination) separate from `TEST_IMAGE` (local test override)

## Quick References (Open These First)

- `Makefile` — Local development targets (build, test, debug, helm-scaffold)
- `README.LOCAL.md` — Developer guide for local workflows
- `.github/workflows/ci.yml` — CI orchestration with PR vs. push separation
- `.github/workflows/templates/container-build.yml` — Multi-arch build recipe (parameterized)
- `apps/radarr/Dockerfile` — Canonical image build pattern
- `apps/radarr/entrypoint.sh` — Template rendering and app startup
- `apps/radarr/config.xml.tmpl` — Configuration template (env var keys and defaults)
- `testhelpers/testhelpers.go` — Test helpers (GetTestImage, TestHTTPEndpoint, TestCommandSucceeds)

## For AI Agents: Immediate Actions

When adding a new app or modifying an existing one:
1. **Dockerfile**: Ensure `TARGETARCH` is handled correctly; include HEALTHCHECK matching app's expected port
2. **Entrypoint**: Use `gomplate` for template expansion; keep `/config` as config directory
3. **Template**: Use `getenv` keys prefixed by app name (e.g., `RADARR__PORT`); include sensible defaults
4. **Test**: Call `testhelpers.TestHTTPEndpoint()` or similar; test passes when container starts and serves HTTP
5. **CI**: No changes needed if you follow the above; ci.yml will auto-detect the new app and run tests

When debugging CI failures:
- Check if HEALTHCHECK port matches template defaults and test expectations
- Verify env var names are consistent across template, entrypoint, and CI job setup
- Run tests locally with `TEST_IMAGE` to reproduce and isolate issues before pushing
