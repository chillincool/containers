#!/usr/bin/env bash
set -e

# Expand environment variables in config.xml.tmpl
if [[ ! -f /config/config.xml ]]; then
	echo "Generating config.xml from template..."
	gomplate -f /config.xml.tmpl -o /config/config.xml --datasource env
fi

# Start Radarr
exec /app/bin/Radarr --nobrowser --data=/config "$@"
