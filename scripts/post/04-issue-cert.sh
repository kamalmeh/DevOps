#!/bin/bash

set -euo pipefail

# Colors
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m"

# Check root
if [[ $EUID -ne 0 ]]; then
  echo -e "${YELLOW}❌ This script must be run as root (use sudo)${NC}" >&2
  exit 1
fi

# Validate required env vars
if [[ -z "${APP_DOMAIN:-}" ]] || [[ -z "${WWW_DOMAIN:-}" ]]; then
  echo -e "${YELLOW}⚠️ APP_DOMAIN and/or WWW_DOMAIN are not set. Skipping certificate issuing.${NC}"
  exit 1
fi

# Check if certbot is installed
if ! command -v certbot &>/dev/null; then
  echo -e "${YELLOW}❌ Certbot is not installed. Please run pre/03-install-certbot.sh first.${NC}"
  exit 1
fi

# Prepare domains
DOMAINS=("-d" "$APP_DOMAIN" "-d" "$WWW_DOMAIN")

# Issue cert
echo -e "${GREEN}🔐 Requesting certificate for ${APP_DOMAIN}, ${WWW_DOMAIN} using Route53 DNS validation...${NC}"

certbot --nginx \
  --dns-route53 \
  "${DOMAINS[@]}" \
  --agree-tos \
  --non-interactive \
  --email "admin@$APP_DOMAIN"

# Check if certificate was issued
CERT_DIR="/etc/letsencrypt/live/$APP_DOMAIN"
if [[ -f "$CERT_DIR/fullchain.pem" ]]; then
  echo -e "${GREEN}✅ Certificate successfully issued for $APP_DOMAIN${NC}"
else
  echo -e "${YELLOW}❌ Certificate issuance failed.${NC}"
  exit 1
fi
