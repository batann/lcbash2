#!/bin/bash

FILE="functions.sh"
TMP=$(mktemp)

# Extract function names
grep '() *{$' "$FILE" | sed 's/()[ \t]*{//'|sed 's!\t!!g' > "$TMP"

mapfile -t funcs < "$TMP"
rm "$TMP"

if ((${#funcs[@]} == 0)); then
    echo "No functions found in $FILE"
    exit 1
fi

# Menu
echo "Available functions:"
for i in "${!funcs[@]}"; do
    printf "[%2d] %s\n" "$((i + 1))" "${funcs[i]}"
done

read -p "Select function by number: " sel
((sel--))

if [[ $sel -ge 0 && $sel -lt ${#funcs[@]} ]]; then
    echo "You selected: ${funcs[sel]}"
else
    echo "Invalid selection."
    exit 1
fi

