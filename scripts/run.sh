#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEPS_DIR="$ROOT_DIR"

run_sorted_scripts() {
  local dir="$1"

  echo "🔧 Running steps in: $dir"

  find "$dir" -maxdepth 1 -type f -name '*.sh' | sort -V | while read -r script; do
    echo "➡️ Executing $(basename "$script")"
    chmod +x "$script"
    bash "$script"
  done
}

# Run stages in order
run_sorted_scripts "$STEPS_DIR/pre"
run_sorted_scripts "$STEPS_DIR/core"
run_sorted_scripts "$STEPS_DIR/post"

echo "✅ All setup steps completed successfully."
