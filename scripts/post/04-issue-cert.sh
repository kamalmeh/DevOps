#!/bin/bash

set -euo pipefail

# Colors
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

# Check for root
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}❌ This script must be run as root (use sudo).${NC}" >&2
  exit 1
fi

# Validate required environment variables
if [[ -z "${APP_DOMAIN:-}" ]] || [[ -z "${WWW_DOMAIN:-}" ]]; then
  echo -e "${YELLOW}⚠️  APP_DOMAIN and/or WWW_DOMAIN not set. Skipping certificate issuance.${NC}"
  exit 0
fi

# Check certbot installed
if ! command -v certbot &>/dev/null; then
  echo -e "${RED}❌ Certbot is not installed. Please run pre/03-install-certbot.sh first.${NC}"
  exit 1
fi

# Check if cert already exists
CERT_DIR="/etc/letsencrypt/live/$APP_DOMAIN"
if [[ -f "$CERT_DIR/fullchain.pem" ]]; then
  echo -e "${YELLOW}⚠️ Certificate for $APP_DOMAIN already exists. Skipping issuance.${NC}"
else
  echo -e "${GREEN}🔐 Requesting certificate for $APP_DOMAIN and $WWW_DOMAIN using Route53 DNS validation...${NC}"
  certbot certonly \
    --dns-route53 \
    -d "$APP_DOMAIN" -d "$WWW_DOMAIN" \
    --agree-tos \
    --non-interactive \
    --email "admin@$APP_DOMAIN"

  # Validate issuance
  if [[ -f "$CERT_DIR/fullchain.pem" ]]; then
    echo -e "${GREEN}✅ Certificate successfully issued for $APP_DOMAIN${NC}"
  else
    echo -e "${RED}❌ Certificate issuance failed. Please check logs above.${NC}"
    exit 1
  fi
fi


# Ensure Nginx helper files are created
if [[ ! -f "/etc/letsencrypt/options-ssl-nginx.conf" ]]; then
  echo -e "${GREEN}⚙️  Running Certbot Nginx install-only to create SSL helper files...${NC}"

  SSL_DIR="/etc/letsencrypt"

  # Ensure directory exists
  sudo mkdir -p "$SSL_DIR"

  # Download options-ssl-nginx.conf if missing
  if [[ ! -f "$SSL_DIR/options-ssl-nginx.conf" ]]; then
    echo -e "${YELLOW}🔧 Downloading options-ssl-nginx.conf...${NC}"
    curl -fsSL -o "$SSL_DIR/options-ssl-nginx.conf" \
      https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams/options-ssl-nginx.conf
  else
    echo -e "${GREEN}✅ options-ssl-nginx.conf already exists.${NC}"
  fi

  # Download ssl-dhparams.pem if missing
  if [[ ! -f "$SSL_DIR/ssl-dhparams.pem" ]]; then
    echo -e "${YELLOW}🔧 Downloading ssl-dhparams.pem...${NC}"
    curl -fsSL -o "$SSL_DIR/ssl-dhparams.pem" \
      https://raw.githubusercontent.com/certbot/certbot/master/certbot/ssl-dhparams/ssl-dhparams.pem
  else
    echo -e "${GREEN}✅ ssl-dhparams.pem already exists.${NC}"
  fi

  echo -e "${GREEN}✅ Certbot SSL config dependencies ensured.${NC}"
else
  echo -e "${GREEN}✅ Certbot Nginx SSL config already exists.${NC}"
fi
