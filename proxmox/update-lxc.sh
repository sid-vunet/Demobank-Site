#!/bin/bash
# =====================================================================
# Script: update-lxc.sh
# Purpose: Update running Proxmox LXC with new source code changes
# Usage: ./update-lxc.sh [proxmox-ip] [ctid]
# Example: ./update-lxc.sh 10.1.92.10 210
# =====================================================================

set -e

# Configuration
PROXMOX_IP=${1:-10.1.92.10}
CTID=${2:-210}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Database Configuration
DB_HOST="${DB_HOST:-10.1.92.130}"
DB_PORT="${DB_PORT:-1521}"
DB_SERVICE="${DB_SERVICE:-XEPDB1}"
DB_USERNAME="${DB_USERNAME:-system}"
DB_PASSWORD="${DB_PASSWORD:-Oracle123!}"

echo "========================================"
echo "  UCO Finacle LXC Update"
echo "========================================"
echo "Proxmox Host: $PROXMOX_IP"
echo "Container ID: $CTID"
echo ""

# Step 1: Build AMD64 image
echo "[1/5] Building AMD64 Docker image..."
cd "$PROJECT_DIR"
docker buildx build --platform linux/amd64 -t uco-finacle:latest --load .

# Step 2: Export image
echo "[2/5] Exporting Docker image..."
docker save uco-finacle:latest | gzip > uco-finacle.tar.gz
echo "✓ Image size: $(du -h uco-finacle.tar.gz | cut -f1)"

# Step 3: Upload to Proxmox
echo "[3/5] Uploading to Proxmox host..."
scp uco-finacle.tar.gz root@$PROXMOX_IP:/root/

# Step 4: Update LXC container
echo "[4/5] Updating LXC container..."
ssh root@$PROXMOX_IP << EOF
set -e
echo "  → Copying image to LXC..."
pct push $CTID /root/uco-finacle.tar.gz /root/uco-finacle.tar.gz

echo "  → Stopping old container..."
pct exec $CTID -- bash -c "docker stop uco-finacle 2>/dev/null || true"
pct exec $CTID -- bash -c "docker rm uco-finacle 2>/dev/null || true"

echo "  → Loading new image..."
pct exec $CTID -- bash -c "gunzip -c /root/uco-finacle.tar.gz | docker load"

echo "  → Starting new container..."
pct exec $CTID -- bash -c "docker run -d --name uco-finacle --restart unless-stopped -p 8080:8080 \
  -e DB_HOST=$DB_HOST \
  -e DB_PORT=$DB_PORT \
  -e DB_SERVICE=$DB_SERVICE \
  -e DB_USERNAME=$DB_USERNAME \
  -e DB_PASSWORD=$DB_PASSWORD \
  uco-finacle:latest"

echo "  → Cleaning up..."
pct exec $CTID -- bash -c "rm /root/uco-finacle.tar.gz"
rm /root/uco-finacle.tar.gz
EOF

# Step 5: Verify
echo "[5/5] Verifying deployment..."
LXC_IP=$(ssh root@$PROXMOX_IP "pct exec $CTID -- hostname -I | awk '{print \$1}'")

echo ""
echo "========================================"
echo "  ✅ Update Complete!"
echo "========================================"
echo ""
echo "Container ID: $CTID"
echo "LXC IP:       $LXC_IP"
echo "Access URL:   http://${LXC_IP}:8080/"
echo ""
echo "Commands:"
echo "  View logs:    ssh root@$PROXMOX_IP \"pct exec $CTID -- docker logs -f uco-finacle\""
echo "  Restart:      ssh root@$PROXMOX_IP \"pct exec $CTID -- docker restart uco-finacle\""
echo "========================================"

# Cleanup local file
rm -f "$PROJECT_DIR/uco-finacle.tar.gz"
