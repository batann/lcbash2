#!/bin/bash

FILE="/home/batan/lcbash/functions/functions.sh"
LCBASHFUNCTIONS=$(cat /home/batan/lcbash/functions/functions.sh |grep "() {"|sed 's!() {!!g'|sed 's!\t!!g');IFS=""
# index function names from fold headers
#awk '/^##<</ { print $2 }' "$FILE" | fzf \
#  --preview="awk '/##<< {}/,/##>> {}/' \"$FILE\"" \
#  --preview-window=up:70% \
#  --bind "enter:execute(echo {})"

 index function names from fold headers
echo $LCBASHFUNCTIONS | fzf \
  --preview="awk '/##<< {}/,/##>> {}/' \"$FILE\"" \
  --preview-window=up:70% \
  --bind "enter:execute(echo {})"
