#!/bin/bash
set -euo pipefail

COUNT="1"
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/114 Safari/537.36"

listenforchanges() {
#clear clipboard and registers
	xclip -selection clipboard /dev/null && xclip -selection primary /dev/null
    previous_clipboard=""

    while true; do
        current_clipboard=$(xclip -o -selection clipboard 2>/dev/null)
     #   cleaned_clipboard=$(echo "$current_clipboard" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

      if [[ $previous_clipboard != $current_clipboard ]]; then
	RRR="$current_clipboard	  "
	sleep 0.5
		  previous_clipboard=$current_clipboard
	  fi
	done
}

listenforchanges &

extractmedia() {
curl -sL -A "$USER_AGENT" "$1" |
  grep -Eo 'https?://[^"]+\.(mp4|m3u8|mpd)(\?[^"]*)?'
}
RRR="test"
 while :; do
	AURL=$(yad --width=1200 --height=50 --undecorated --no-buttons --form --field="URL $COUNT " "$RRR")

if [[ -z "$AURL" ]]; then
break
fi



extractmedia $AURL |grep m3u8 >> list100

 ((COUNT++))
done

BCD="$(cat list100|wc -l)"
CDE="0"
for x in $(cat list100); do
	clear
echo -e "Links to Download = $(( $BCD - $CDE ))"
yt-dlp $x
((CDE++))
done

