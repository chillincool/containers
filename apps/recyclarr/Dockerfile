# syntax=docker/dockerfile:1

ARG VERSION=7.5.2

FROM recyclarr/recyclarr:${VERSION}

ARG VENDOR

LABEL org.opencontainers.image.source="https://github.com/chillincool/containers"

USER root

RUN chown -R 568:568 /config

USER 568:568
