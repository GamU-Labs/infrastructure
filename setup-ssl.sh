#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <droplet-ip> [ssh-user]"
  echo "  droplet-ip - Droplet IP"
  echo "  ssh-user    - SSH user (default: root)"
  exit 1
fi

DROPLET_IP=$1
SSH_USER=${2:-root}
SSH_DEST="${SSH_USER}@${DROPLET_IP}"
DEPLOY_DIR="/opt/capstone"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

DOMAINS=("gamu.svega.me" "gamu-be.svega.me")

echo "==> 1. Removing ssl.conf and starting nginx (HTTP only) ..."
ssh "$SSH_DEST" "rm -f $DEPLOY_DIR/conf.d/ssl.conf && cd $DEPLOY_DIR && docker compose up -d nginx"

echo "==> 2. Running certbot for each domain ..."
for DOMAIN in "${DOMAINS[@]}"; do
  echo "    Certbot for $DOMAIN ..."
  ssh "$SSH_DEST" "
    docker run --rm \
      -v capstone_certbot-www:/var/www/certbot \
      -v capstone_certbot-certs:/etc/letsencrypt \
      certbot/certbot certonly --webroot \
      --webroot-path /var/www/certbot \
      --email ssl@svega.me \
      --agree-tos \
      --no-eff-email \
      -d $DOMAIN
  "
done

echo "==> 3. Copying ssl.conf and restarting nginx ..."
scp "$SCRIPT_DIR/nginx-ssl.conf" "$SSH_DEST:$DEPLOY_DIR/conf.d/ssl.conf"
ssh "$SSH_DEST" "cd $DEPLOY_DIR && docker compose restart nginx"

echo ""
echo "Done! All domains should be live with HTTPS."
for DOMAIN in "${DOMAINS[@]}"; do
  echo "  https://$DOMAIN"
done