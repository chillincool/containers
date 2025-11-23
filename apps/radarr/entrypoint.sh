#!/usr/bin/env bash
set -e

# Expand environment variables in config.xml.tmpl
if [[ ! -f /config/config.xml ]]; then
    echo "Generating config.xml from template..."
    envsubst < /app/config.xml.tmpl > /config/config.xml
fi

# Start Radarr
exec /app/bin/Radarr --nobrowser --data=/config "$@"
