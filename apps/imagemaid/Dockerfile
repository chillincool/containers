# syntax=docker/dockerfile:1
FROM python:3.13-slim

ARG VERSION=master

LABEL org.opencontainers.image.source="https://github.com/Kometa-Team/ImageMaid"
LABEL org.opencontainers.image.title="imagemaid"
LABEL org.opencontainers.image.description="Python script to clean up unused Plex metadata images"

ENV IMAGEMAID_DOCKER=True \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

WORKDIR /

# Install system dependencies
RUN apt-get update && \
    apt-get upgrade -y --no-install-recommends && \
    apt-get install -y --no-install-recommends \
        tzdata \
        gcc g++ \
        libxml2-dev libxslt-dev libz-dev \
        libjpeg62-turbo-dev zlib1g-dev \
        wget curl git ca-certificates && \
    git clone --depth 1 -b ${VERSION} https://github.com/Kometa-Team/ImageMaid.git /imagemaid || \
    git clone --depth 1 https://github.com/Kometa-Team/ImageMaid.git /imagemaid && \
    cd /imagemaid && \
    pip3 install --no-cache-dir --upgrade -r requirements.txt && \
    apt-get --purge autoremove gcc g++ libxml2-dev libxslt-dev libz-dev -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /imagemaid

# Create config and plex directories with proper permissions
RUN mkdir -p /config /plex && \
    chown -R 568:568 /imagemaid /config /plex && \
    chmod -R 755 /imagemaid /config /plex

VOLUME /config
VOLUME /plex

USER 568:568

ENTRYPOINT ["python3", "imagemaid.py"]
CMD ["--config", "/config"]
