#!/bin/bash

file="/home/batan/lcbash/functions/functions.sh"

# List all functions by name using fzf
LCBASHFUNCTIONS=$(grep '() {' "$file" | sed 's/() {//' | tr -d '\t')
fname=$(echo "$LCBASHFUNCTIONS" | fzf)

# Find start of function using fold marker format: `#{{{ >>> funcname >#123`
#start=$(grep -P "#\{\{\{ >>>\s+$fname\s+>\#\K[0-9]+" "$file")
#end=$(grep -Po "#}}} <\#\K[0-9]+" "$file" | awk -v s="$start" '$1 > s { print; exit }')


# Get function fold headers with their actual line numbers
start=$(awk "/#{{{ >>> *$fname *>#[0-9]+/"'{ print NR, $0 }' "$file" | \
         sed -n "s/^\([0-9]\+\).*>\#\([0-9]\+\)/\2/p")

end=$(grep -Po "#}}} <\#\K[0-9]+" "$file" | awk -v s="$start" '$1 > s { print; exit }')



# Debug (optional)
echo "Function: $fname"
echo "Start line: $start"
echo "End line: $end"

# Source the function via process substitution
source <(sed -n "${start},${end}p" "$file")
typeset -f "$fname"
