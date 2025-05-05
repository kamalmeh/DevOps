#!/bin/bash

echo "🔒 Checking for root privileges..."

if [[ $EUID -ne 0 ]]; then
  echo "❌ This script must be run as root."
  exit 1
fi

echo "✔️ Running as root."
