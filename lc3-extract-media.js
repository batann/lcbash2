#!/bin/bash
set -euo pipefail
RRR=""
COUNT="1"
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/114 Safari/537.36"
FILE="/home/batan/.config/lc-clipboard/URLS"
listenforchanges() {
#clear clipboard and registers
	xclip -selection clipboard /dev/null && xclip -selection primary /dev/null
    previous_clipboard=""

    while true; do
        current_clipboard=$(xclip -o -selection clipboard 2>/dev/null)
     #   cleaned_clipboard=$(echo "$current_clipboard" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

      if [[ $previous_clipboard != $current_clipboard ]]; then
	echo "$current_clipboard" |grep https >/dev/null 2>&1
	if [[ $? == "0" ]]; then
echo "$current_clipboard	  " >> $FILE
	sleep 0.5
		  previous_clipboard=$current_clipboard
	  fi
	fi
	done
}

listenforchanges &

	watch cat $FILE
