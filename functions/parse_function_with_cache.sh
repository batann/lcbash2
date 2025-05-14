#1/bin/bash
parse_function_with_cache() {
  local file_path="$1"       # The file that contains functions
  local func_name="$2"       # The function name to extract
  local cache_dir="/tmp/function_cache"  # Cache directory
  
  # Ensure cache directory exists
  mkdir -p "$cache_dir"

  # Check if the function has been cached already
  local cached_file="$cache_dir/$func_name.sh"
  if [[ -f "$cached_file" ]]; then
    # If cached, just source it
    echo "Function '$func_name' found in cache. Sourcing..."
    source "$cached_file"
    return 0
  fi

  # If not cached, extract the function and cache it
  echo "Function '$func_name' not found in cache. Extracting..."
  
  # Extract the function from the file using awk
  awk "/^$func_name\(\)/, /^}/" "$file_path" > "$cached_file"

  if [[ -s "$cached_file" ]]; then
    # If successfully cached, source it
    source "$cached_file"
    echo "Function '$func_name' cached and sourced."
    return 0
  else
    echo "Function '$func_name' not found in '$file_path'."
    return 1
  fi
}
file="functions.sh"
parse_function_with_cache $file set_ssh
echo $cached_file
# Example usage
# parse_function_with_cache "/path/to/functions_file.sh" "my_function"

