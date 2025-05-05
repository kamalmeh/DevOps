#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEPS_DIR="$ROOT_DIR"
ENV_FILE="$ROOT_DIR/.env"

# ----------------------
# Load environment vars
# ----------------------

# Export CLI args first
if [[ $# -gt 0 ]]; then
  echo "📦 Loading environment variables from CLI args"
  for arg in "$@"; do
    export "$arg"
    echo "✅ Exported $arg"
  done
elif [[ -f "$ENV_FILE" ]]; then
  echo "📦 No CLI args. Loading from fallback: $ENV_FILE"
  set -a
  source "$ENV_FILE"
  set +a
else
  echo "⚠️  No CLI args or .env file found. Continuing without environment variables."
fi

# ----------------------
# Run all step scripts
# ----------------------

run_sorted_scripts() {
  local dir="$1"

  echo "🔧 Running steps in: $dir"

  find "$dir" -maxdepth 1 -type f -name '*.sh' | sort -V | while read -r script; do
    echo "➡️ Executing $(basename "$script")"
    chmod +x "$script"
    bash "$script"
  done
}

run_sorted_scripts "$STEPS_DIR/pre"
run_sorted_scripts "$STEPS_DIR/core"
run_sorted_scripts "$STEPS_DIR/post"

echo "✅ All setup steps completed successfully."
