#!/bin/sh
set -e

# Default config path
CONFIG_PATH="/opt/focalboard/config.json"

# Log environment for debugging
echo "=== Focalboard Startup ==="
echo "PORT: ${PORT:-not set (will use config default)}"
echo "FOCALBOARD_SERVERROOT: ${FOCALBOARD_SERVERROOT:-not set (will use config default)}"
echo "Config path: $CONFIG_PATH"

# If FOCALBOARD_SERVERROOT is not set, try to construct it from common environment variables
# This is critical - the frontend needs the correct serverRoot to connect
if [ -z "$FOCALBOARD_SERVERROOT" ]; then
    if [ -n "$PUBLIC_URL" ]; then
        export FOCALBOARD_SERVERROOT="$PUBLIC_URL"
        echo "Set FOCALBOARD_SERVERROOT from PUBLIC_URL: $PUBLIC_URL"
    elif [ -n "$COOLIFY_FQDN" ]; then
        # Coolify specific - construct URL from FQDN
        PROTOCOL="http"
        if [ -n "$COOLIFY_SSL_ENABLED" ] && [ "$COOLIFY_SSL_ENABLED" = "true" ]; then
            PROTOCOL="https"
        fi
        export FOCALBOARD_SERVERROOT="${PROTOCOL}://${COOLIFY_FQDN}"
        echo "Set FOCALBOARD_SERVERROOT from COOLIFY_FQDN: $FOCALBOARD_SERVERROOT"
    elif [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
        # Railway specific
        export FOCALBOARD_SERVERROOT="https://${RAILWAY_PUBLIC_DOMAIN}"
        echo "Set FOCALBOARD_SERVERROOT from RAILWAY_PUBLIC_DOMAIN: $FOCALBOARD_SERVERROOT"
    else
        echo "WARNING: FOCALBOARD_SERVERROOT not set. Frontend may not be able to connect."
        echo "Set FOCALBOARD_SERVERROOT environment variable to your public URL (e.g., https://yourdomain.com)"
    fi
fi

# Build command arguments
if [ -n "$PORT" ]; then
    echo "Starting server with PORT=$PORT and config=$CONFIG_PATH"
    exec /opt/focalboard/bin/focalboard-server -config "$CONFIG_PATH" -port "$PORT"
else
    echo "Starting server with config=$CONFIG_PATH (using port from config)"
    exec /opt/focalboard/bin/focalboard-server -config "$CONFIG_PATH"
fi

