extract_fold_by_name() {
    local name="$1"
    local file="/home/batan/lcbash/functions/functions.sh"

    local start=$(grep -P "#\{\{\{ >>>\s+${name}\s+>\#\K[0-9]+" "$file")
    [[ -z "$start" ]] && echo "Start not found for '$name'" && return 1

    local end=$(awk -v s="$start" '
        /^\#\}\}\} <\#[0-9]+/ {
            match($0, /<\#([0-9]+)/, a)
            if (a[1] > s) {
                print a[1]
                exit
            }
        }
    ' "$file")

    [[ -z "$end" ]] && echo "End not found for '$name'" && return 1

    sed -n "${start},${end}p" "$file"
}


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
extract_fold_by_name $fname


# Echo the function
sed -n "${start},${end}p" "$file"

# Or source it dynamically
source <(sed -n "${start},${end}p" "$file")




