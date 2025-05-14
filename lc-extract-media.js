#!/bin/bash
set -euo pipefail

URL="$1"
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/114 Safari/537.36"

curl -sL -A "$USER_AGENT" "$URL" |
  grep -Eo 'https?://[^"]+\.(mp4|m3u8|mpd)(\?[^"]*)?' |
  sort -u

