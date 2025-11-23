# syntax=docker/dockerfile:1

FROM alpine:3.22
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

ARG TARGETARCH
ARG VENDOR
ARG VERSION
ARG GOMPLATE_VERSION=v4.3.3

ENV DOTNET_EnableDiagnostics=0 \
    SONARR__UPDATE__BRANCH=develop

USER root
WORKDIR /app

# Install dependencies and download Sonarr
RUN apk add --no-cache \
        bash \
        ca-certificates \
        catatonit \
        coreutils \
        curl \
        gomplate \
        icu-libs \
        jq \
        libintl \
        nano \
        sqlite-libs \
        tzdata \
    && mkdir -p /app/bin \
    && case "$TARGETARCH" in \
         amd64) ARCH="x64" ;; \
         arm64) ARCH="arm64" ;; \
         *) ARCH="$TARGETARCH" ;; \
       esac \
    && curl -fsSL "https://services.sonarr.tv/v1/download/${SONARR__UPDATE__BRANCH}/latest?version=4&os=linuxmusl&arch=${ARCH}" \
        | tar xzf - -C /app/bin --strip-components=1 \
    && printf "UpdateMethod=docker\nBranch=%s\nPackageVersion=%s\nPackageAuthor=[%s](https://github.com/%s)\n" \
         "${SONARR__UPDATE__BRANCH}" "${VERSION}" "${VENDOR}" "${VENDOR}" > /app/package_info \
    && chown -R root:root /app \
    && chmod -R 755 /app \
    && rm -rf /tmp/* /app/bin/Sonarr.Update

# Copy entrypoint script and config templates
COPY . /

# Ensure entrypoint script is executable
RUN chmod +x /entrypoint.sh

USER nobody:nogroup
WORKDIR /config
VOLUME ["/config"]

# Healthcheck to ensure Sonarr is running
HEALTHCHECK --interval=30s --timeout=10s --start-period=45s --retries=3 \
  CMD curl -fsS http://localhost:8989/ping || exit 1

# OCI metadata
LABEL org.opencontainers.image.source="https://github.com/chillincool/containers"

# Entrypoint
ENTRYPOINT ["/usr/bin/catatonit", "--", "/entrypoint.sh"]
