#!/bin/bash

set -euo pipefail

# File to persist env variables
ENV_FILE="/etc/profile.d/app-server-env.sh"

# Ensure script is run with sudo/root
if [[ $EUID -ne 0 ]]; then
  echo "❌ This script must be run as root (use sudo)" >&2
  exit 1
fi

# List of supported environment variable keys
VARS=("APP_ENV" "DB_HOST" "AWS_REGION" "APP_NAME")

echo "🔧 Creating environment persistence script at $ENV_FILE"
echo "#!/bin/bash" > "$ENV_FILE"
echo "#============================================================" >> "$ENV_FILE"
echo "# APP SERVER EXPORTS DEFINED BY SERVER SETUP SCRIPT - START #" >> "$ENV_FILE"
echo "#============================================================" >> "$ENV_FILE"

for VAR in "${VARS[@]}"; do
  VALUE="${!VAR:-}"
  if [[ -n "$VALUE" ]]; then
    echo "export $VAR=\"$VALUE\"" >> "$ENV_FILE"
    echo "✅ Set $VAR=$VALUE"
  else
    echo "⚠️  $VAR not set. Skipping."
  fi
done

echo "#============================================================" >> "$ENV_FILE"
echo "# APP SERVER EXPORTS DEFINED BY SERVER SETUP SCRIPT - END   #" >> "$ENV_FILE"
echo "#============================================================" >> "$ENV_FILE"

chmod +x "$ENV_FILE"
echo "✅ Environment variables persisted to $ENV_FILE"
