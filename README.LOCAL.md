# Local Development Guide

This document explains how to build, test, and debug container images locally without using GitHub Actions.

## Prerequisites

- Docker & docker-buildx installed and configured
- Go 1.21+ installed (for running tests)
- Make installed

## Quick Start

### Build a container locally (single-arch, fast)

```bash
make build-image APP=radarr
```

This creates a local image at `ghcr.io/chillincool/containers/radarr:local`.

### Run tests against your local build

```bash
TEST_IMAGE=ghcr.io/chillincool/containers/radarr:local make test APP=radarr
```

This runs the container tests using your locally-built image instead of the default.

### Debug a container

```bash
make debug-run APP=radarr IMAGE=ghcr.io/chillincool/containers/radarr:local
```

This starts an interactive shell in the container so you can inspect files, configs, etc.

## Makefile Targets

```makefile
make help                # Show all available targets

make build-image         # Build single-arch image (fast, local Docker)
make buildx              # Build multi-arch image with buildx and load into Docker
make test                # Run go test for the app
make debug-run           # Start a shell in the built image
make helm-scaffold       # Create a minimal Helm chart skeleton
```

## Local Testing Workflow

Here's a typical workflow for developing a container:

### 1. Make changes to the app (Dockerfile, entrypoint, etc.)

Edit files in `apps/radarr/`:

```bash
# Example: edit the Dockerfile or entrypoint script
vim apps/radarr/Dockerfile
vim apps/radarr/entrypoint.sh
```

### 2. Build locally to validate

```bash
make build-image APP=radarr
# Output: Image built: ghcr.io/chillincool/containers/radarr:local
```

### 3. Run tests against your build

```bash
TEST_IMAGE=ghcr.io/chillincool/containers/radarr:local make test APP=radarr
```

If tests pass, you're ready to commit. If they fail, debug the container:

### 4. Debug failures

```bash
make debug-run APP=radarr IMAGE=ghcr.io/chillincool/containers/radarr:local
```

Inside the shell, you can:

- Check `/config` directory contents
- Inspect `/app` structure
- Run commands to diagnose issues
- Check logs

Exit with `exit` or `Ctrl+D`.

### 5. Push to GitHub

Once tests pass locally:

```bash
git add apps/radarr/
git commit -m "Update radarr container"
git push origin feature-branch
```

## CI Workflows Explained

### Pull Requests (Cheap, Fast)

When you push a PR, GitHub Actions runs:

1. **Detect changed apps** — compares against main branch
2. **Single-arch build** — only builds for `linux/amd64` (fast)
3. **Run tests** — validates the container works
4. **No push** — doesn't push to GHCR (saves bandwidth and time)

This gives you fast feedback (~2-3 minutes).

### Push to main (Full Build)

When your PR is merged and you push to main:

1. **Multi-arch build** — builds for both `linux/amd64` and `linux/arm64`
2. **Push to GHCR** — publishes with `:latest` and `:${{ github.sha }}` tags
3. **Run tests** — validates the pushed image

This is the "expensive" workflow, but only happens on main.

## Environment Variables

### TEST_IMAGE

Override the default test image:

```bash
TEST_IMAGE=my-image:tag make test APP=radarr
```

Without this, tests use the image hardcoded in `apps/radarr/container_test.go`.

### APP

Specify which app to work with:

```bash
make build-image APP=sonarr  # Build sonarr instead of radarr
```

Defaults to `radarr` if not specified.

### IMAGE

Specify the image tag (for `make debug-run`, etc.):

```bash
make debug-run APP=radarr IMAGE=my-custom-image:v1.0
```

Defaults to `ghcr.io/chillincool/containers/{APP}:local`.

## Cost Comparison

| Workflow | Time | Cost (approx.) |
|----------|------|----------------|
| `make build-image` | 1-2 min | Free (local Docker) |
| `make test` | 1 min | Free (local Docker) |
| PR in CI | 2-3 min | ~$0.007 (single-arch) |
| Push to main CI | 10-15 min | ~$0.035 (multi-arch) |

**Recommendation**: Use local `make` commands for development and testing. Push to GitHub only when you're ready. PRs are cheap; the full multi-arch build only happens on main.

## Troubleshooting

### "command not found: docker"

Install Docker Desktop or ensure Docker is in your PATH.

### "DOCKER_BUILDKIT not enabled"

Enable buildkit:

```bash
export DOCKER_BUILDKIT=1
```

Or add to your shell profile for persistence.

### "Test failed: port already in use"

If tests fail with "port 7878 already in use", you have a container still running:

```bash
docker ps
docker stop <container-id>
```

### "Image not found" when running tests

Make sure you built the image first:

```bash
TEST_IMAGE=ghcr.io/chillincool/containers/radarr:local make test
# This will fail if the image doesn't exist
```

Build it first:

```bash
make build-image APP=radarr
TEST_IMAGE=ghcr.io/chillincool/containers/radarr:local make test
```

## Next Steps

- Read `.github/copilot-instructions.md` for technical architecture details
- Review `apps/radarr/` to understand the Dockerfile patterns
- Run tests locally before pushing to GitHub to catch issues early
