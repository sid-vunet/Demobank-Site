#!/bin/bash
# Export Docker image for Proxmox deployment

set -e

echo "========================================"
echo "  Export UCO Finacle for Proxmox"
echo "========================================"

IMAGE_NAME="uco-finacle:latest"
OUTPUT_FILE="uco-finacle.tar.gz"

# Check if image exists
if ! docker image inspect "$IMAGE_NAME" &> /dev/null; then
    echo "Error: Docker image '$IMAGE_NAME' not found."
    echo "Please build it first: docker build -t uco-finacle:latest ."
    exit 1
fi

echo "[1/2] Exporting Docker image..."
docker save "$IMAGE_NAME" | gzip > "$OUTPUT_FILE"

FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
echo "[2/2] Export complete!"
echo ""
echo "========================================"
echo "  Export Summary"
echo "========================================"
echo "File: $OUTPUT_FILE"
echo "Size: $FILE_SIZE"
echo ""
echo "Next steps:"
echo "1. Copy to Proxmox LXC:"
echo "   scp $OUTPUT_FILE root@<lxc-ip>:/root/"
echo ""
echo "2. Inside LXC, load and run:"
echo "   gunzip -c /root/$OUTPUT_FILE | docker load"
echo "   docker run -d --name uco-finacle -p 8080:8080 uco-finacle:latest"
echo ""
echo "3. Access: http://<lxc-ip>:8080/"
echo "========================================"
