#!/usr/bin/env bash
set -e

# Start Tautulli
exec python3 /app/Tautulli.py --datadir=/config "$@"
