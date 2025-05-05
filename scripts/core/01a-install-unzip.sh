#!/bin/bash

echo "📦 Installing Unzip..."

if command -v unzip &> /dev/null; then
  echo "✔️ unzip already installed."
else
  apt-get install unzip
  echo "✔️ unzip installed successfully."
fi

unzip --version
