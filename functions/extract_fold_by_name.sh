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

