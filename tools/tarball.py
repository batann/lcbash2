import os
import tarfile

# Define base structure
base_dir = "/mnt/data/lcbash_tools_templates"
templates = {
    "template-rust": {
        "Cargo.toml": """[package]
name = "example"
version = "0.1.0"
edition = "2021"

[dependencies]
""",
        "src/main.rs": """fn main() {
    println!("Hello from Rust!");
}
""",
        "init-rust.sh": """#!/bin/bash
set -e
dst=${1:-myrustapp}
cp -r "$(dirname "$0")/template-rust" "$dst"
cd "$dst"
rm -f init-rust.sh
sed -i "s/example/$dst/" Cargo.toml
echo "Created Rust project at $dst"
"""
    },
    "template-python": {
        "pyproject.toml": """[project]
name = "example"
version = "0.1.0"
description = "Minimal Python project"
authors = [{name = "Your Name"}]
requires-python = ">=3.7"
""",
        "src/main.py": """def main():
    print("Hello from Python!")

if __name__ == "__main__":
    main()
""",
        "init-python.sh": """#!/bin/bash
set -e
dst=${1:-mypythonapp}
cp -r "$(dirname "$0")/template-python" "$dst"
cd "$dst"
rm -f init-python.sh
sed -i "s/example/$dst/" pyproject.toml
echo "Created Python project at $dst"
"""
    },
    "template-cpp": {
        "Makefile": """CXX = g++
CXXFLAGS = -std=c++17 -Wall -O2

TARGET = main

all: $(TARGET)

main: src/main.cpp
\t$(CXX) $(CXXFLAGS) -o $@ $^

clean:
\trm -f $(TARGET)
""",
        "src/main.cpp": """#include <iostream>

int main() {
    std::cout << "Hello from C++!" << std::endl;
    return 0;
}
""",
        "init-cpp.sh": """#!/bin/bash
set -e
dst=${1:-mycppapp}
cp -r "$(dirname "$0")/template-cpp" "$dst"
cd "$dst"
rm -f init-cpp.sh
echo "Created C++ project at $dst"
"""
    }
}

# Create directory and files
os.makedirs(base_dir, exist_ok=True)
for template, files in templates.items():
    for file_path, content in files.items():
        full_path = os.path.join(base_dir, template, file_path)
        os.makedirs(os.path.dirname(full_path), exist_ok=True)
        with open(full_path, "w") as f:
            f.write(content)

# Create tarball
tar_path = "/mnt/data/lcbash-tools-templates.tar.gz"
with tarfile.open(tar_path, "w:gz") as tar:
    tar.add(base_dir, arcname="lcbash/tools")

tar_path

