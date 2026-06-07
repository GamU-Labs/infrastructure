#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <domain> [droplet-ip] [ssh-user]"
  echo "  domain     - Your domain (e.g., api.example.com)"
  echo "  droplet-ip - Droplet IP (default: uses first argument from tofu output)"
  exit 1
fi

DOMAIN=$1
DROPLET_IP=${2:-}
SSH_USER=${3:-root}

if [ -z "$DROPLET_IP" ]; then
  DROPLET_IP=$(tofu output -raw ipv4_address 2>/dev/null || echo "")
fi

if [ -z "$DROPLET_IP" ]; then
  echo "Error: droplet-ip required. Pass it as second arg or run from infrastructure/ dir after tofu apply."
  exit 1
fi

echo "==> 1. Applying SSL config with domain $DOMAIN on droplet $DROPLET_IP ..."
ssh "$SSH_USER@$DROPLET_IP" "mkdir -p /opt/capstone/ssl"

scp nginx-ssl.conf "$SSH_USER@$DROPLET_IP:/opt/capstone/nginx-ssl.conf"

ssh "$SSH_USER@$DROPLET_IP" "
  sed -i 's/DOMAIN/$DOMAIN/g' /opt/capstone/nginx-ssl.conf
  sed -i 's/DOMAIN/$DOMAIN/g' /opt/capstone/nginx.conf

  cd /opt/capstone

  echo '==> 2. Starting nginx with HTTP only for certbot ...'
  docker compose up -d nginx

  echo '==> 3. Running certbot ...'
  docker run --rm \
    -v certbot-certs:/etc/letsencrypt \
    -v certbot-www:/var/www/certbot \
    certbot/certbot certonly --webroot \
    --webroot-path /var/www/certbot \
    --email ssl@$DOMAIN \
    --agree-tos \
    --no-eff-email \
    -d $DOMAIN

  echo '==> 4. Restarting nginx with HTTPS ...'
  docker compose up -d nginx
"

echo ""
echo "Done! https://$DOMAIN should be live."
echo "Renewal is automatic via certbot systemd timer."
