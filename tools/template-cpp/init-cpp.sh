#!/bin/bash
set -e
dst=${1:-mycppapp}
cp -r "$(dirname "$0")/template-cpp" "$dst"
cd "$dst"
rm -f init-cpp.sh
echo "Created C++ project at $dst"

