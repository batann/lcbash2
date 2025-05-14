#!/bin/bash
set -e
dst=${1:-myrustapp}
cp -r "$(dirname "$0")/template-rust" "$dst"
cd "$dst"
rm -f init-rust.sh
sed -i "s/example/$dst/" Cargo.toml
echo "Created Rust project at $dst"

