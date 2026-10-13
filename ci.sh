#!/usr/bin/env bash
set -euo pipefail

cmake -S . -B build
cmake --build build
ctest --test-dir build --output-on-failure

if [ -x "build/hello" ]; then
  echo "Hello binary exists: build/hello"
else
  echo "Missing build/hello" >&2
  exit 1
fi
