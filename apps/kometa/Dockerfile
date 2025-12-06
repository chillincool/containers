# syntax=docker/dockerfile:1
FROM python:3.13-slim

ARG VERSION=master

LABEL org.opencontainers.image.source="https://github.com/Kometa-Team/Kometa"
LABEL org.opencontainers.image.title="kometa"
LABEL org.opencontainers.image.description="Python script to update Plex metadata and build collections"

ENV KOMETA_DOCKER=True \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

WORKDIR /

# Install system dependencies and tini
RUN apt-get update && \
    apt-get upgrade -y --no-install-recommends && \
    apt-get install -y --no-install-recommends \
        tzdata \
        gcc g++ \
        libxml2-dev libxslt-dev libz-dev \
        libjpeg62-turbo-dev zlib1g-dev \
        wget curl git ca-certificates && \
    git clone --depth 1 -b ${VERSION} https://github.com/Kometa-Team/Kometa.git /kometa || \
    git clone --depth 1 https://github.com/Kometa-Team/Kometa.git /kometa && \
    cd /kometa && \
    pip3 install --no-cache-dir --upgrade -r requirements.txt && \
    apt-get --purge autoremove gcc g++ libxml2-dev libxslt-dev libz-dev -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /kometa

# Create config directory with proper permissions
RUN mkdir -p /config && \
    chown -R 568:568 /kometa /config && \
    chmod -R 755 /kometa /config

VOLUME /config

USER 568:568

ENTRYPOINT ["python3", "kometa.py"]
CMD ["--config", "/config"]
