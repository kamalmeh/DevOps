#!/bin/bash

echo "🔍 Verifying awscli installation..."

if ! command -v aws &>/dev/null; then
  echo "❌ AWS CLI is not installed or not in PATH."
  exit 1
fi

if ! aws sts get-caller-identity &>/dev/null; then
  echo "⚠️ AWS CLI installed but not configured with valid credentials."
else
  echo "✔️ AWS CLI is installed and can communicate with AWS."
fi