#!/bin/sh
set -e

# Default config path
CONFIG_PATH="/opt/focalboard/config.json"

# If PORT environment variable is set (Railway provides this), use it
if [ -n "$PORT" ]; then
    exec /opt/focalboard/bin/focalboard-server -config "$CONFIG_PATH" -port "$PORT"
else
    exec /opt/focalboard/bin/focalboard-server -config "$CONFIG_PATH"
fi

