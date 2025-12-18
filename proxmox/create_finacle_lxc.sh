#!/bin/bash
# =====================================================================
# Script: create_finacle_lxc.sh
# Purpose: Create a Proxmox LXC container and run UCO Finacle Docker app
# Usage: sudo ./create_finacle_lxc.sh
# Prerequisites: Copy uco-finacle.tar.gz to /root/ on Proxmox host first
# =====================================================================

set -e  # Exit on error

# =========================
# CONFIGURATION
# =========================
CTID=210
HOSTNAME="uco-finacle"
TEMPLATE="debian-12-standard_12.12-1_amd64.tar.zst"
# Alternative templates:
# TEMPLATE="ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
# TEMPLATE="ubuntu-24.04-standard_24.04-2_amd64.tar.zst"

STORAGE="local-zfs"
DISK_SIZE_GB=10
MEM_MB=2048
CORES=2
BRIDGE="vmbr0"
IP_CIDR="dhcp"
PASSWORD="FinacleRoot123!"

# Database Configuration
DB_HOST="10.1.92.130"
DB_PORT="1521"
DB_SERVICE="XEPDB1"
DB_USERNAME="system"
DB_PASSWORD="Oracle123!"

# Docker image file (should be in /root/ on Proxmox host)
IMAGE_FILE="/root/uco-finacle.tar.gz"

# =========================
# 0️⃣ PRE-CHECK
# =========================
echo "🔹 Checking for Docker image file..."
if [ ! -f "$IMAGE_FILE" ]; then
    echo "❌ Error: Docker image not found at $IMAGE_FILE"
    echo "Please copy uco-finacle.tar.gz to /root/ first:"
    echo "  scp uco-finacle.tar.gz root@<proxmox-ip>:/root/"
    exit 1
fi
echo "✅ Docker image found: $IMAGE_FILE"

# =========================
# 1️⃣ CREATE LXC CONTAINER
# =========================
echo "🔹 Creating Finacle LXC container ($CTID)..."
pct create $CTID /var/lib/vz/template/cache/$TEMPLATE \
    --hostname $HOSTNAME \
    --storage $STORAGE \
    --rootfs ${STORAGE}:${DISK_SIZE_GB} \
    --memory $MEM_MB \
    --cores $CORES \
    --net0 name=eth0,bridge=$BRIDGE,ip=$IP_CIDR,type=veth \
    --password $PASSWORD \
    --features nesting=1,keyctl=1 \
    --unprivileged 0 \
    --start 1

echo "🔹 Waiting for container to start..."
sleep 10

# =========================
# 2️⃣ INSTALL DOCKER
# =========================
echo "🔹 Installing Docker inside LXC..."
pct exec $CTID -- bash -c "apt update && DEBIAN_FRONTEND=noninteractive apt install -y curl gnupg lsb-release ca-certificates"

pct exec $CTID -- bash -c "curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg"

pct exec $CTID -- bash -c 'ARCH=$(dpkg --print-architecture) && CODENAME=$(lsb_release -cs) && echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $CODENAME stable" > /etc/apt/sources.list.d/docker.list'

pct exec $CTID -- bash -c "apt update && DEBIAN_FRONTEND=noninteractive apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin"

pct exec $CTID -- bash -c "systemctl enable docker && systemctl start docker"

# =========================
# 3️⃣ COPY DOCKER IMAGE
# =========================
echo "🔹 Copying Docker image to LXC..."
pct push $CTID $IMAGE_FILE /root/uco-finacle.tar.gz

# =========================
# 4️⃣ LOAD DOCKER IMAGE
# =========================
echo "🔹 Loading Docker image (this may take a minute)..."
pct exec $CTID -- bash -c "\
    gunzip -c /root/uco-finacle.tar.gz | docker load && \
    rm /root/uco-finacle.tar.gz \
"

# =========================
# 5️⃣ RUN FINACLE CONTAINER
# =========================
echo "🔹 Starting Finacle container..."
pct exec $CTID -- bash -c "\
    docker run -d \
        --name uco-finacle \
        --restart unless-stopped \
        -p 8080:8080 \
        -e DB_HOST=${DB_HOST} \
        -e DB_PORT=${DB_PORT} \
        -e DB_SERVICE=${DB_SERVICE} \
        -e DB_USERNAME=${DB_USERNAME} \
        -e DB_PASSWORD=${DB_PASSWORD} \
        uco-finacle:latest \
"

# =========================
# 6️⃣ WAIT FOR STARTUP
# =========================
echo "🔹 Waiting for application to start..."
sleep 15

# =========================
# 7️⃣ VERIFY
# =========================
echo "🔹 Verifying Finacle is running..."
pct exec $CTID -- docker ps --filter name=uco-finacle --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Get LXC IP
LXC_IP=$(pct exec $CTID -- hostname -I | awk '{print $1}')

# =========================
# DONE
# =========================
echo ""
echo "========================================"
echo "✅ UCO Finacle LXC Setup Complete!"
echo "========================================"
echo "CT ID:        $CTID"
echo "Hostname:     $HOSTNAME"
echo "LXC IP:       $LXC_IP"
echo "App Port:     8080"
echo "Root Password: $PASSWORD"
echo ""
echo "Access URL:   http://${LXC_IP}:8080/"
echo "Login:        admin / admin123"
echo ""
echo "Database:     ${DB_HOST}:${DB_PORT}/${DB_SERVICE}"
echo ""
echo "Commands:"
echo "  Enter LXC:    pct enter $CTID"
echo "  View logs:    pct exec $CTID -- docker logs -f uco-finacle"
echo "  Restart app:  pct exec $CTID -- docker restart uco-finacle"
echo "========================================"
