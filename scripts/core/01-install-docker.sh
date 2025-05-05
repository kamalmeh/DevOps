#!/bin/bash

echo "📦 Installing Docker..."

if command -v docker &> /dev/null; then
  echo "✔️ Docker already installed."
else
  curl -fsSL https://get.docker.com | sh
  systemctl enable docker
  systemctl start docker
  echo "✔️ Docker installed successfully."
fi

docker --version
