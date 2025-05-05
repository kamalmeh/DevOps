#!/bin/bash

set -euo pipefail

echo -e "\e[36m🔧 Installing Certbot with Route53 plugin for Nginx...\e[0m"

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
  echo -e "\e[31m❌ This script must be run as root (use sudo)\e[0m" >&2
  exit 1
fi

# Install required packages
apt-get update -y
apt-get install -y software-properties-common

# Install Certbot and the Route53 plugin
apt-get update -y
apt-get install -y certbot python3-certbot-dns-route53 python3-certbot-nginx

# Confirm installation
if command -v certbot >/dev/null 2>&1; then
  echo -e "\e[32m✅ Certbot installed successfully\e[0m"
else
  echo -e "\e[31m❌ Certbot installation failed\e[0m" >&2
  exit 1
fi

# Verify Nginx plugin
if certbot plugins | grep -q nginx; then
  echo -e "\e[32m✅ Certbot Nginx plugin is available\e[0m"
else
  echo -e "\e[31m❌ Certbot Nginx plugin not found\e[0m"
  exit 1
fi

# Verify Route53 plugin
if certbot plugins | grep -q dns-route53; then
  echo -e "\e[32m✅ Certbot Route53 plugin is available\e[0m"
else
  echo -e "\e[31m❌ Certbot Route53 plugin not found\e[0m"
  exit 1
fi

echo -e "\e[36m🛡️ Certbot with Route53 DNS validation for Nginx is ready for use.\e[0m"
