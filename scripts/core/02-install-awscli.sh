#!/bin/bash

echo "📦 Installing AWS CLI..."

if command -v aws &> /dev/null; then
  echo "✔️ AWS CLI already installed."
else
  ARCH=$(uname -m)
  if [[ "$ARCH" == "aarch64" ]]; then
    URL="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"
  else
    URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
  fi

  curl -sSL "$URL" -o awscliv2.zip
  unzip -q awscliv2.zip
  sudo ./aws/install --update
  rm -rf aws awscliv2.zip
  echo "✔️ AWS CLI installed successfully."
fi

aws --version
