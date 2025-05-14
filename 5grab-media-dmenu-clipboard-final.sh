#!/bin/bash
set -euo pipefail

# Check for dependencies
#for bin in node xclip dmenu yt-dlp mpv ffmpeg; do
#    command -v "$bin" >/dev/null || { echo "$bin is required but not installed."; exit 1; }
#done

# URL input or clipboard fallback
URL="${1:-$(xclip -o -selection clipboard 2>/dev/null || true)}"
[[ "$URL" =~ ^https?:// ]] || { echo "Invalid or missing URL."; exit 1; }

TMP=$(mktemp)
LOG="$HOME/.local/share/grab-media.log"
mkdir -p "$(dirname "$LOG")"

# Extract media URLs
if ! node extract-media.js "$URL" >"$TMP"; then
    echo "Media extraction failed." >&2
    rm -f "$TMP"
    exit 1
fi

mapfile -t MEDIA_URLS < <(grep -Ei '\.(m3u8|mpd|mp4)(\?|$)' "$TMP")
rm -f "$TMP"

[ "${#MEDIA_URLS[@]}" -eq 0 ] && { echo "No media URLs found."; exit 1; }

# Select media
SELECTED=$(printf '%s\n' "${MEDIA_URLS[@]}" | dmenu -l 10 -p "Select media URL:")
[ -z "$SELECTED" ] && exit 0

# Choose action
ACTION=$(printf "Download (yt-dlp)\nStream (mpv)\nRecord (ffmpeg bg)" | dmenu -l 5 -p "Action:")
[ -z "$ACTION" ] && exit 0

echo "$(date '+%Y-%m-%d %H:%M:%S') [$ACTION] $SELECTED" >> "$LOG"

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

