# syntax=docker/dockerfile:1
FROM docker.io/library/ubuntu:24.04

ARG TARGETARCH
ARG VENDOR
ARG VERSION

ENV DEBIAN_FRONTEND="noninteractive" \
    NVIDIA_DRIVER_CAPABILITIES="compute,video,utility" \
    PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/config/Library/Application Support" \
    PLEX_MEDIA_SERVER_HOME="/usr/lib/plexmediaserver" \
    PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS="6" \
    PLEX_MEDIA_SERVER_INFO_VENDOR="Docker" \
    PLEX_MEDIA_SERVER_INFO_DEVICE="Docker Container (${VENDOR})"

USER root

WORKDIR /app

RUN \
    apt-get update \
    && \
    apt-get install -y --no-install-recommends --no-install-suggests \
        bash \
        ca-certificates \
        catatonit \
        coreutils \
        curl \
        jq \
        nano \
        tzdata \
        uuid-runtime \
        xmlstarlet \
    && \
    curl -fsSL -o /tmp/plex.deb \
        "https://downloads.plex.tv/plex-media-server-new/${VERSION}/debian/plexmediaserver_${VERSION}_${TARGETARCH}.deb" \
    && \
    dpkg -i /tmp/plex.deb \
    && chmod -R 755 "${PLEX_MEDIA_SERVER_HOME}" \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /etc/default/plexmediaserver /tmp/* /var/lib/apt/lists/* /var/tmp/

COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

USER 568:568

WORKDIR /config

VOLUME ["/config"]

EXPOSE 32400

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:32400/web/index.html || exit 1

ENTRYPOINT ["/usr/bin/catatonit", "--", "/entrypoint.sh"]
