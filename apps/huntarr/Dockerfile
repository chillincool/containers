FROM python:3.9-slim AS cloner

ARG VERSION=main

RUN apt-get update && apt-get install -y --no-install-recommends git && \
    git clone --depth 1 -b $VERSION https://github.com/plexguide/Huntarr.io.git /source || \
    git clone --depth 1 https://github.com/plexguide/Huntarr.io.git /source && \
    rm -rf /var/lib/apt/lists/*

# Final stage
FROM python:3.9-slim

LABEL org.opencontainers.image.source="https://github.com/plexguide/Huntarr.io"
LABEL org.opencontainers.image.title="huntarr"
LABEL org.opencontainers.image.description="Huntarr - Automated torrent management"

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    net-tools \
    curl \
    wget \
    nano \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements and install Python packages
COPY --from=cloner /source/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY --from=cloner /source /app

# Create config directory with proper permissions
RUN mkdir -p /config && \
    chown -R 568:568 /config && \
    chmod -R 755 /config

# Set environment variables
ENV PYTHONPATH=/app
ENV TZ=UTC

# Expose port
EXPOSE 9705

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:9705/health || exit 1

USER 568:568

CMD ["python3", "main.py"]
