# syntax=docker/dockerfile:1
FROM node:18.18.2-alpine AS builder

ARG TARGETPLATFORM
ARG TARGETARCH
ARG VERSION

WORKDIR /app

# Install build dependencies for ARM (only when building for ARM platforms)
# Check both TARGETPLATFORM and TARGETARCH since they may not be set in non-buildx builds
RUN \
  case "${TARGETPLATFORM:-}${TARGETARCH:-}" in \
    *arm64*|*armv7*|*arm/v7*) \
      echo "Installing ARM build dependencies..." && \
      apk update && \
      apk add --no-cache python3 make g++ gcc libc6-compat bash && \
      yarn global add node-gyp \
      ;; \
    *) \
      echo "Skipping ARM build dependencies (not an ARM platform)"; \
      true \
      ;; \
  esac

# Download and extract source tarball
RUN apk add --no-cache curl && \
    curl -fsSL -o /tmp/overseerr.tar.gz \
        "https://github.com/sct/overseerr/archive/refs/tags/${VERSION}.tar.gz" && \
    tar -xzf /tmp/overseerr.tar.gz -C /tmp && \
    mv /tmp/overseerr-${VERSION#v}/* /app/ && \
    rm -rf /tmp/overseerr.tar.gz /tmp/overseerr-${VERSION#v}

# Install dependencies and build
RUN CYPRESS_INSTALL_BINARY=0 yarn install --frozen-lockfile --network-timeout 1000000
RUN yarn build
RUN yarn install --production --ignore-scripts --prefer-offline
RUN rm -rf src server .next/cache
RUN touch config/DOCKER

# Final stage
FROM node:18.18.2-alpine

LABEL org.opencontainers.image.source="https://github.com/sct/overseerr"
LABEL org.opencontainers.image.title="overseerr"
LABEL org.opencontainers.image.description="Request management and media discovery tool for Plex"

WORKDIR /app

RUN apk add --no-cache tzdata tini && rm -rf /tmp/*

# Copy built application
COPY --from=builder /app ./

# Create config directory with proper permissions
RUN mkdir -p /config && \
    chown -R 568:568 /config /app && \
    chmod -R 755 /config

ENV NODE_ENV=production

EXPOSE 5055

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:5055/api/v1/status || exit 1

USER 568:568

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["yarn", "start"]
