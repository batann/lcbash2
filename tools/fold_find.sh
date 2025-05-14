#!/bin/bash

# Usage: fold_find.sh <function_name> <file_name>
# Example: fold_find.sh str_trim.sh functions/str_trim.sh

function_name="$1"
file_name="$2"

# Ensure both arguments are provided
if [[ -z "$function_name" || -z "$file_name" ]]; then
    echo "Usage: $0 <function_name> <file_name>"
    exit 1
fi

# Check if the file exists
if [[ ! -f "$file_name" ]]; then
    echo "File '$file_name' does not exist."
    exit 1
fi

# Find the start and end of the fold by searching for the markers
start_line=$(grep -n "#{{{>>> $function_name" "$file_name" | cut -d: -f1)
end_line=$(grep -n "#}}}" "$file_name" | cut -d: -f1)

# If start or end not found, report it
if [[ -z "$start_line" ]]; then
    echo "Start marker not found for '$function_name' in '$file_name'."
    exit 1
fi

if [[ -z "$end_line" ]]; then
    echo "End marker not found for '$function_name' in '$file_name'."
    exit 1
fi

echo "Function '$function_name' in '$file_name' starts at line $start_line and ends at line $end_line."

