#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEPS_DIR="$ROOT_DIR"
ENV_FILE="$ROOT_DIR/.env"

# 1. Load all variables from .env (if present)
if [[ -f "$ENV_FILE" ]]; then
  echo "📦 Loading environment variables from $ENV_FILE"
  set -a
  source "$ENV_FILE"
  set +a
else
  echo "⚠️  No .env file found. Proceeding without it."
fi

# 2. Override only those from CLI args
if [[ $# -gt 0 ]]; then
  echo "📦 Overriding variables from CLI args"
  for arg in "$@"; do
    export "$arg"
    echo "✅ CLI override: $arg"
  done
fi

# Run steps in order
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

if [ -f /etc/profile.d/app-server-env.sh ]; then
  echo "🔁 Run below command to source environment variables to current shell with below command."
  echo "Run `source /etc/profile.d/app-server-env.sh`"
else
  echo "⚠️  Warning: env export script not found. Skipping immediate application. Open a new shell or reboot the server to take it into effect."
fi

