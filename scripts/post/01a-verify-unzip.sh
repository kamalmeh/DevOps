#!/bin/bash

echo "🔍 Verifying unzip installation..."

# Validate Docker
if ! command -v unzip &>/dev/null; then
  echo "❌ Unzip is not installed or not in PATH."
  exit 1
fi

if ! unzip version &>/dev/null; then
  echo "❌ Unzip is installed but not working correctly (daemon may be down)."
  exit 1
fi

echo "✔️ Unzip is installed and running: $(unzip --version)"
