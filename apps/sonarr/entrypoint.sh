#!/usr/bin/env bash
set -e

# Expand environment variables in config.xml.tmpl
if [[ ! -f /config/config.xml ]]; then
	echo "Generating config.xml from template..."
	gomplate -f /config.xml.tmpl -o /config/config.xml --datasource env
fi

# Start Sonarr
exec /app/bin/Sonarr --nobrowser --data=/config "$@"
