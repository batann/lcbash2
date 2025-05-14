#!/bin/bash

FILE="/home/batan/lcbash/functions/functions.sh"
file="/home/batan/lcbash/functions/functions.sh"
LCBASHFUNCTIONS=$(cat /home/batan/lcbash/functions/functions.sh |grep "() {"|sed 's!() {!!g'|sed 's!\t!!g');IFS=""
# index function names from fold headers
#awk '/^##<</ { print $2 }' "$FILE" | fzf \
#  --preview="awk '/##<< {}/,/##>> {}/' \"$FILE\"" \
#  --preview-window=up:70% \
#  --bind "enter:execute(echo {})"

# index function names from fold headers
 fname=$(echo $LCBASHFUNCTIONS | fzf)


# Extract start line from the fold marker
start=$(grep -Po "#{{{ >>>\s+$fname\s+>\#\K[0-9]+" "$file") >#17

# From all end markers, find the first one greater than the start
end=$(grep -Po "#}}} <\#\K[0-9]+" "$file" | awk -v s="$start" '$1 > s { print; exit }') <#20

# Echo the function
sed -n "${start},${end}p" "$file"

# Or source it dynamically
source <(sed -n "${start},${end}p" "$file")




end=$(grep -Po "#}}} <\#\K[0-9]+" "$file" | awk -v s="$start" '$1 > s { print; exit }') <#31
