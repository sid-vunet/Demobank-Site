#!/bin/bash
# =====================================================================
# UCO Bank Finacle - Bundle Creator
# Creates a single deployable package for any Linux VM
# Usage: ./create-bundle.sh
# =====================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUNDLE_DIR="$SCRIPT_DIR"
OUTPUT_NAME="uco-finacle-bundle"

echo "========================================"
echo "  UCO Finacle Bundle Creator"
echo "========================================"

# Step 1: Check if AMD64 image exists
echo "[1/4] Checking Docker image..."
if ! docker image inspect uco-finacle:latest &> /dev/null; then
    echo "Building Docker image for AMD64..."
    cd "$PROJECT_DIR"
    docker buildx build --platform linux/amd64 -t uco-finacle:latest --load .
fi

# Step 2: Export Docker image
echo "[2/4] Exporting Docker image..."
docker save uco-finacle:latest | gzip > "$BUNDLE_DIR/uco-finacle.tar.gz"
echo "✓ Image exported: $(du -h "$BUNDLE_DIR/uco-finacle.tar.gz" | cut -f1)"

# Step 3: Make deploy script executable
echo "[3/4] Preparing deploy script..."
chmod +x "$BUNDLE_DIR/deploy.sh"

# Step 4: Create the bundle tarball
echo "[4/4] Creating bundle..."
cd "$BUNDLE_DIR"
tar -cvzf "../${OUTPUT_NAME}.tar.gz" deploy.sh uco-finacle.tar.gz

BUNDLE_SIZE=$(du -h "$PROJECT_DIR/${OUTPUT_NAME}.tar.gz" | cut -f1)

echo ""
echo "========================================"
echo "  ✅ Bundle Created Successfully!"
echo "========================================"
echo ""
echo "Bundle: ${OUTPUT_NAME}.tar.gz ($BUNDLE_SIZE)"
echo "Location: $PROJECT_DIR/${OUTPUT_NAME}.tar.gz"
echo ""
echo "To deploy on any Linux VM:"
echo ""
echo "  1. Copy bundle to target server:"
echo "     scp ${OUTPUT_NAME}.tar.gz user@server:/tmp/"
echo ""
echo "  2. SSH to server and extract:"
echo "     cd /tmp && tar -xzf ${OUTPUT_NAME}.tar.gz"
echo ""
echo "  3. Run deployment:"
echo "     sudo ./deploy.sh"
echo ""
echo "Optional: Set custom database before deploying:"
echo "  export DB_HOST=your-db-host"
echo "  export DB_PORT=1521"
echo "  export DB_SERVICE=XEPDB1"
echo "  export DB_USERNAME=system"
echo "  export DB_PASSWORD=your-password"
echo "  sudo -E ./deploy.sh"
echo ""
echo "========================================"
