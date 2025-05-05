#!/bin/bash

set -euo pipefail

# Colors
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m"

echo -e "${GREEN}🌐 Installing Nginx...${NC}"

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
  echo -e "${YELLOW}❌ This script must be run as root (use sudo)${NC}" >&2
  exit 1
fi

# Install Nginx
apt-get update -y
apt-get install -y nginx

# Enable and start the service
systemctl enable nginx
systemctl start nginx

# Validate installation
if command -v nginx &>/dev/null; then
  echo -e "${GREEN}✅ Nginx installed successfully${NC}"
else
  echo -e "${YELLOW}❌ Nginx installation failed${NC}"
  exit 1
fi

# Show status
systemctl status nginx --no-pager
