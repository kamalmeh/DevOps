#!/bin/bash

set -euo pipefail

# Resolve ROOT directory (project root where run.sh and .env live)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="/etc/profile.d/app-server-env.sh"
DOTENV_FILE="$ROOT_DIR/.env"

# Ensure script is run with sudo/root
if [[ $EUID -ne 0 ]]; then
  echo -e "\e[31m❌ This script must be run as root (use sudo)\e[0m" >&2
  exit 1
fi

# Ensure .env exists
if [[ ! -f "$DOTENV_FILE" ]]; then
  echo -e "\e[31m❌ .env file not found at: $DOTENV_FILE\e[0m" >&2
  exit 1
fi

echo -e "\e[32m🔧 Loading variables from .env and current shell environment...\e[0m"

# Read all variable keys from .env
ALL_VARS=$(grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "$DOTENV_FILE" | cut -d '=' -f1)

echo "🔧 Creating environment persistence script at $ENV_FILE"
echo "#!/bin/bash" > "$ENV_FILE"
echo "#============================================================" >> "$ENV_FILE"
echo "# APP SERVER EXPORTS DEFINED BY SERVER SETUP SCRIPT - START #" >> "$ENV_FILE"
echo "#============================================================" >> "$ENV_FILE"

for VAR in $ALL_VARS; do
  # Get from current shell first, fallback to .env
  VALUE="${!VAR:-$(grep "^$VAR=" "$DOTENV_FILE" | cut -d '=' -f2-)}"

  if [[ -n "$VALUE" ]]; then
    echo "export $VAR=\"$VALUE\"" >> "$ENV_FILE"
    echo -e "\e[32m✅ Set $VAR=$VALUE\e[0m"

    # Warn for dummy values
    if [[ "$VALUE" =~ ^(changeme|dummy|to_be_set)?$ ]]; then
      echo -e "\e[33m⚠️  WARNING: $VAR is using a dummy value: '$VALUE'. Please override via CLI or .env.\e[0m"
    fi
  else
    echo -e "\e[33m⚠️  $VAR not set or empty. Skipping.\e[0m"
  fi
done

echo "#============================================================" >> "$ENV_FILE"
echo "# APP SERVER EXPORTS DEFINED BY SERVER SETUP SCRIPT - END   #" >> "$ENV_FILE"
echo "#============================================================" >> "$ENV_FILE"

chmod +x "$ENV_FILE"
echo -e "\e[32m✅ Environment variables persisted to $ENV_FILE\e[0m"
