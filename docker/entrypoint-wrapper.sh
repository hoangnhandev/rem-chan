#!/bin/sh
set -e

# Install extra packages needed by daily-news skill
apk add --no-cache bash jq python3 curl 2>/dev/null || true

# Run original entrypoint
exec /entrypoint.sh "$@"
