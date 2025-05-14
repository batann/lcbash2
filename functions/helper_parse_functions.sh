parse_function() {
  local file_path="$1"    # The file that contains functions
  local func_name="$2"    # The function name to extract
  local temp_file="$3"    # Optional: a temp file to store the extracted function

  # Check if the file exists
  if [[ ! -f "$file_path" ]]; then
    echo "File '$file_path' not found."
    return 1
  fi

  # Extract the function and its content
  awk "/^$func_name\(\)/, /^}/" "$file_path" > "$temp_file"
  
  if [[ -s "$temp_file" ]]; then
    # If a temp file is provided, we print the extracted function
    cat "$temp_file"
    return 0
  else
    echo "Function '$func_name' not found in '$file_path'."
    return 1
  fi
}

# Example usage
# parse_function "/path/to/functions_file.sh" "my_function" "/tmp/extracted_function.sh"

