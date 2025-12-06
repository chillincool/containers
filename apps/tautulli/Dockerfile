FROM alpine:3.22

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

ARG VERSION=2.16.0

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    TAUTULLI_DOCKER="True"

RUN apk add --no-cache \
    bash \
    ca-certificates \
    catatonit \
    curl \
    python3 \
    py3-pip \
    py3-lxml \
    py3-openssl \
    py3-setuptools \
    openssl \
    tar \
    gzip \
    jq

WORKDIR /app

# Download and extract Tautulli
RUN curl -fsSL "https://github.com/Tautulli/Tautulli/archive/refs/tags/${VERSION}.tar.gz" \
        | tar xzf - -C /app --strip-components 1

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER nobody:nogroup
WORKDIR /config
VOLUME ["/config"]


HEALTHCHECK --interval=30s --timeout=10s --start-period=45s --retries=3 \
    CMD curl -f http://localhost:8181/ &> /dev/null || exit 1


ENTRYPOINT ["/usr/bin/catatonit", "--"]
CMD ["/entrypoint.sh"]
