#!/bin/bash
# Run this script INSIDE the Proxmox LXC container
# Sets up Docker and runs the Finacle application

set -e

echo "========================================"
echo "  UCO Finacle LXC Setup"
echo "========================================"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

echo "[1/5] Updating system..."
apt update && apt upgrade -y

echo "[2/5] Installing dependencies..."
apt install -y curl gnupg lsb-release ca-certificates

echo "[3/5] Installing Docker..."
# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# Install Docker
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "[4/5] Starting Docker..."
systemctl enable docker
systemctl start docker

echo "[5/5] Docker installed successfully!"
echo ""
echo "========================================"
echo "  Setup Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Copy the image file to this LXC:"
echo "   scp uco-finacle.tar.gz root@$(hostname -I | awk '{print $1}'):/root/"
echo ""
echo "2. Load the image:"
echo "   gunzip -c /root/uco-finacle.tar.gz | docker load"
echo ""
echo "3. Run the container:"
echo "   docker run -d --name uco-finacle --restart unless-stopped -p 8080:8080 uco-finacle:latest"
echo ""
echo "4. Access: http://$(hostname -I | awk '{print $1}'):8080/"
echo "========================================"
