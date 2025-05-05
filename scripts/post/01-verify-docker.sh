#!/bin/bash

echo "🔍 Verifying docker installation..."

# Validate Docker
if ! command -v docker &>/dev/null; then
  echo "❌ Docker is not installed or not in PATH."
  exit 1
fi

if ! docker version &>/dev/null; then
  echo "❌ Docker is installed but not working correctly (daemon may be down)."
  exit 1
fi

echo "✔️ Docker is installed and running: $(docker --version)"
