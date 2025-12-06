# syntax=docker/dockerfile:1
# Stage 1: Build Vue.js client
FROM node:22-alpine AS client-builder

ARG VERSION=main

WORKDIR /tmp

RUN apk add --no-cache git && \
    git clone --depth 1 -b ${VERSION} https://github.com/giuseppe99barchetta/SuggestArr.git /source || \
    git clone --depth 1 https://github.com/giuseppe99barchetta/SuggestArr.git /source

WORKDIR /source/client

RUN npm install && npm cache clean --force
RUN npm run build

# Stage 2: Final image
FROM python:3.13-alpine

LABEL org.opencontainers.image.source="https://github.com/giuseppe99barchetta/SuggestArr"
LABEL org.opencontainers.image.title="suggestarr"
LABEL org.opencontainers.image.description="Automated media recommendations for Jellyfin/Plex/Emby to Jellyseer/Overseer"

WORKDIR /app/api_service

# Install Python dependencies
COPY --from=client-builder /source/api_service/requirements.txt /app/api_service/
RUN pip install --no-cache-dir -r requirements.txt

# Copy client build files
COPY --from=client-builder /source/client/dist /app/static

# Copy api_service source
COPY --from=client-builder /source/api_service/ /app/api_service/

# Copy and setup entrypoint
COPY --from=client-builder /source/docker/docker_entrypoint.sh /app/
RUN chmod +x /app/docker_entrypoint.sh

# Create log files
RUN touch /var/log/gunicorn.log /var/log/gunicorn_error.log

# Create config directory with proper permissions
RUN mkdir -p /app/config/config_files && \
    chown -R 568:568 /app /var/log/gunicorn*.log && \
    chmod -R 755 /app/config

ENV LOG_LEVEL=info \
    SUGGESTARR_PORT=5000 \
    PYTHONUNBUFFERED=1

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:5000/ || exit 1

USER 568:568

ENTRYPOINT ["/app/docker_entrypoint.sh"]
CMD ["--host", "0.0.0.0", "--port", "5000", "--log-level", "info"]
