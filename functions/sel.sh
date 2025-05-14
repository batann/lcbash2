file="/home/batan/lcbash/functions/functions.sh"

fname=$(grep -Po '#\{\{\{ >>>\s+\K\S+' "$file" | fzf)
start=$(awk "/#{{{ >>> *$fname *>#[0-9]+/ { match(\$0, />#([0-9]+)/, m); print m[1]; exit }" "$file")
end=$(grep -Po "#}}} <\#\K[0-9]+" "$file" | awk -v s="$start" '$1 > s { print; exit }')

echo "Extracting lines $start to $end for function '$fname'..."
sed -n "${start},${end}p" "$file" >> temp
source temp


echo "Sourcing..."
source <(sed -n "${start},${end}p" "$file") || { echo "Sourcing failed"; exit 1; }

echo "Checking function:"
declare -f "$fname" || echo "Function $fname not found after sourcing"
