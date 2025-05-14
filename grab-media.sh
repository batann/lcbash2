#!/bin/bash
set -e

URL="$1"
[ -z "$URL" ] && { echo "Usage: $0 <url>"; exit 1; }

# Temp file to capture media links
TMP=$(mktemp)

# Run puppeteer script
node extract-media.js "$URL" | tee "$TMP"

# Try yt-dlp on each line
while read -r media_url; do
  case "$media_url" in
    *.m3u8*|*.mpd*|*.mp4*)
      echo "Attempting download with yt-dlp: $media_url"
      yt-dlp "$media_url"
      break
      ;;
  esac
done < "$TMP"

rm -f "$TMP"

