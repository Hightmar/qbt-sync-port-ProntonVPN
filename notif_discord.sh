#!/bin/bash

WEBHOOK_URL="https://discord.com/api/webhooks/[...]"
PORT=$1
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if [[ "$PORT" == "fail" ]]; then
    COLOR=15158332
    JSON_PAYLOAD=$(printf '{"content":"","embeds":[{"title":"Port qBittorrent update","description":"❌ Qbittorrent port update failed","color":%d,"timestamp":"%s"}]}' "$COLOR" "$TIMESTAMP")
else
    COLOR=3066993
    JSON_PAYLOAD=$(printf '{"content":"","embeds":[{"title":"Port qBittorrent update":"✅ qBittorrent port successfully updated.\\n🔌 New port : %s","color":%d,"timestamp":"%s"}]}' "$PORT" "$COLOR" "$TIMESTAMP")

fi

curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD" \
  > /dev/null 2>&1