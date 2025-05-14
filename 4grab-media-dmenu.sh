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

# dmenu: media selection
SELECTED=$(printf '%s\n' "${MEDIA_URLS[@]}" | dmenu -l 10 -p "Select media URL:")
[ -z "$SELECTED" ] && exit 1

# dmenu: action selection
ACTION=$(printf "Download (yt-dlp)\nStream (mpv)\nRecord (ffmpeg bg)" | dmenu -l 5 -p "Action:")
[ -z "$ACTION" ] && exit 1

case "$ACTION" in
  "Download (yt-dlp)")
    setsid -f urxvt -e yt-dlp "$SELECTED"
    ;;
  "Stream (mpv)")
    setsid -f mpv "$SELECTED"
    ;;
  "Record (ffmpeg bg)")
    OUT="record-$(date +%Y%m%d-%H%M%S).mp4"
    ffmpeg -i "$SELECTED" -c copy -bsf:a aac_adtstoasc "$OUT" </dev/null >/dev/null 2>&1 &
    notify-send "Recording started: $OUT"
    ;;
esac

