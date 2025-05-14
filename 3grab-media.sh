#!/bin/bash
set -euo pipefail

URL="$1"
[ -z "$URL" ] && { echo "Usage: $0 <url>"; exit 1; }

TMP=$(mktemp)

# Extract media URLs
node extract-media.js "$URL" | tee "$TMP"

mapfile -t MEDIA_URLS < <(grep -Ei '\.(m3u8|mpd|mp4)(\?|$)' "$TMP")
rm -f "$TMP"

[ "${#MEDIA_URLS[@]}" -eq 0 ] && { echo "No media URLs found."; exit 1; }

# User selects media URL
SELECTED=$(printf '%s\n' "${MEDIA_URLS[@]}" | fzf --height=10 --reverse --border --prompt="Choose media: ")
[ -z "$SELECTED" ] && exit 1

# User selects action
ACTION=$(printf "Download (yt-dlp)\nStream (mpv)\nRecord (ffmpeg bg)" | fzf --height=6 --reverse --border --prompt="Action: ")

case "$ACTION" in
  "Download (yt-dlp)")
    yt-dlp "$SELECTED"
    ;;
  "Stream (mpv)")
    mpv "$SELECTED"
    ;;
  "Record (ffmpeg bg)")
    OUT="record-$(date +%Y%m%d-%H%M%S).mp4"
    echo "Recording to $OUT..."
    nohup ffmpeg -i "$SELECTED" -c copy -bsf:a aac_adtstoasc "$OUT" </dev/null >/dev/null 2>&1 &
    echo "Recording started in background with PID $!"
    ;;
esac

