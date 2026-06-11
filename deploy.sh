#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <droplet-ip> [ssh-user]"
  echo "  droplet-ip  - IP address of the DigitalOcean droplet"
  echo "  ssh-user    - SSH user (default: root)"
  exit 1
fi

DROPLET_IP=$1
SSH_USER=${2:-root}
SSH_DEST="${SSH_USER}@${DROPLET_IP}"
DEPLOY_DIR="/opt/capstone"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Copying docker-compose, nginx configs, and env to $SSH_DEST:$DEPLOY_DIR ..."
ssh "$SSH_DEST" "mkdir -p $DEPLOY_DIR/conf.d"
rsync -az --progress \
  "$SCRIPT_DIR/docker-compose.yml" \
  "$SSH_DEST:$DEPLOY_DIR/"
rsync -az --progress \
  "$SCRIPT_DIR/conf.d/" \
  "$SSH_DEST:$DEPLOY_DIR/conf.d/"

if [ ! -f "$SCRIPT_DIR/backend.env" ]; then
  echo "WARNING: backend.env not found! Creating placeholder."
  echo "# Create backend.env with your actual env vars" > "$SCRIPT_DIR/backend.env"
fi
rsync -az --progress \
  "$SCRIPT_DIR/backend.env" \
  "$SSH_DEST:$DEPLOY_DIR/"

echo "Pulling latest images and restarting services ..."
ssh "$SSH_DEST" "
  cd $DEPLOY_DIR
  docker compose pull
  docker compose up -d --remove-orphans
"

echo "Done! App should be available at http://$DROPLET_IP"
