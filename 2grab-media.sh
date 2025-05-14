#!/bin/bash
set -euo pipefail

URL="$1"
[ -z "$URL" ] && { echo "Usage: $0 <url>"; exit 1; }

TMP=$(mktemp)

# Run Puppeteer script to get media links
node extract-media.js "$URL" | tee "$TMP"

# Filter for media URLs
mapfile -t MEDIA_URLS < <(grep -Ei '\.(m3u8|mpd|mp4)(\?|$)' "$TMP")

# Bail if nothing found
[ "${#MEDIA_URLS[@]}" -eq 0 ] && { echo "No media URLs found."; rm -f "$TMP"; exit 1; }

# If only one URL found, auto-download
if [ "${#MEDIA_URLS[@]}" -eq 1 ]; then
  echo "Single media URL found:"
  echo "${MEDIA_URLS[0]}"
  yt-dlp "${MEDIA_URLS[0]}"
else
  # Use fzf for user selection
  echo "Multiple media URLs found. Select one to download:"
  SELECTED=$(printf '%s\n' "${MEDIA_URLS[@]}" | fzf --height=10 --reverse --border --prompt="Choose: ")
  [ -n "$SELECTED" ] && yt-dlp "$SELECTED"
fi

rm -f "$TMP"

