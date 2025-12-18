#!/bin/bash
# =====================================================================
# UCO Bank Finacle - Single-Command Deployment Script
# Works on: Ubuntu 20.04/22.04/24.04, Debian 11/12, RHEL/CentOS/Rocky 8/9
# Usage: ./deploy.sh
# =====================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =========================
# CONFIGURATION
# =========================
APP_NAME="uco-finacle"
IMAGE_NAME="uco-finacle:latest"
IMAGE_FILE="uco-finacle.tar.gz"
APP_PORT=8080

# Database Configuration (modify as needed)
DB_HOST="${DB_HOST:-10.1.92.130}"
DB_PORT="${DB_PORT:-1521}"
DB_SERVICE="${DB_SERVICE:-XEPDB1}"
DB_USERNAME="${DB_USERNAME:-system}"
DB_PASSWORD="${DB_PASSWORD:-Oracle123!}"

# =========================
# FUNCTIONS
# =========================

print_banner() {
    echo -e "${BLUE}"
    echo "========================================"
    echo "  UCO Bank Finacle Deployment"
    echo "  Single-Command Installer"
    echo "========================================"
    echo -e "${NC}"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Please run as root: sudo ./deploy.sh"
        exit 1
    fi
}

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    else
        log_error "Cannot detect OS. /etc/os-release not found."
        exit 1
    fi
    log_info "Detected OS: $OS $VERSION"
}

install_docker_debian() {
    log_info "Installing Docker on Debian/Ubuntu..."
    
    apt-get update -qq
    apt-get install -y -qq curl gnupg lsb-release ca-certificates apt-transport-https
    
    # Add Docker GPG key
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/$OS/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
    
    apt-get update -qq
    apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-compose-plugin
}

install_docker_rhel() {
    log_info "Installing Docker on RHEL/CentOS/Rocky/Alma..."
    
    yum install -y -q yum-utils
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum install -y -q docker-ce docker-ce-cli containerd.io docker-compose-plugin
}

install_docker() {
    if command -v docker &> /dev/null; then
        log_success "Docker is already installed"
        docker --version
        return
    fi
    
    log_info "Docker not found. Installing..."
    
    case $OS in
        ubuntu|debian)
            install_docker_debian
            ;;
        centos|rhel|rocky|almalinux|fedora)
            install_docker_rhel
            ;;
        *)
            log_error "Unsupported OS: $OS"
            log_info "Please install Docker manually and run this script again."
            exit 1
            ;;
    esac
    
    # Start and enable Docker
    systemctl enable docker
    systemctl start docker
    
    log_success "Docker installed successfully"
}

check_image_file() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    IMAGE_PATH="$SCRIPT_DIR/$IMAGE_FILE"
    
    if [ ! -f "$IMAGE_PATH" ]; then
        log_error "Docker image not found: $IMAGE_PATH"
        log_info "Make sure $IMAGE_FILE is in the same directory as this script."
        exit 1
    fi
    
    log_success "Docker image found: $IMAGE_PATH"
}

load_docker_image() {
    log_info "Loading Docker image (this may take a minute)..."
    
    # Check if image already exists
    if docker image inspect "$IMAGE_NAME" &> /dev/null; then
        log_warn "Image $IMAGE_NAME already exists. Removing old version..."
        docker rmi "$IMAGE_NAME" 2>/dev/null || true
    fi
    
    gunzip -c "$IMAGE_PATH" | docker load
    log_success "Docker image loaded successfully"
}

stop_existing_container() {
    if docker ps -a --format '{{.Names}}' | grep -q "^${APP_NAME}$"; then
        log_warn "Stopping and removing existing container..."
        docker stop "$APP_NAME" 2>/dev/null || true
        docker rm "$APP_NAME" 2>/dev/null || true
    fi
}

run_container() {
    log_info "Starting Finacle container..."
    
    docker run -d \
        --name "$APP_NAME" \
        --restart unless-stopped \
        -p ${APP_PORT}:8080 \
        -e DB_HOST="$DB_HOST" \
        -e DB_PORT="$DB_PORT" \
        -e DB_SERVICE="$DB_SERVICE" \
        -e DB_USERNAME="$DB_USERNAME" \
        -e DB_PASSWORD="$DB_PASSWORD" \
        "$IMAGE_NAME"
    
    log_success "Container started successfully"
}

wait_for_startup() {
    log_info "Waiting for application to start..."
    
    for i in {1..30}; do
        if curl -s -o /dev/null -w "%{http_code}" "http://localhost:${APP_PORT}/finacle/fininfra/ui/SSOLogin.jsp" | grep -q "200"; then
            log_success "Application is ready!"
            return
        fi
        sleep 2
        echo -n "."
    done
    
    echo ""
    log_warn "Application may still be starting. Check logs with: docker logs -f $APP_NAME"
}

configure_firewall() {
    log_info "Configuring firewall..."
    
    # UFW (Ubuntu/Debian)
    if command -v ufw &> /dev/null; then
        ufw allow ${APP_PORT}/tcp 2>/dev/null || true
        log_success "UFW: Port $APP_PORT opened"
    fi
    
    # firewalld (RHEL/CentOS)
    if command -v firewall-cmd &> /dev/null; then
        firewall-cmd --permanent --add-port=${APP_PORT}/tcp 2>/dev/null || true
        firewall-cmd --reload 2>/dev/null || true
        log_success "firewalld: Port $APP_PORT opened"
    fi
}

print_summary() {
    # Get server IP
    SERVER_IP=$(hostname -I | awk '{print $1}')
    
    echo ""
    echo -e "${GREEN}========================================"
    echo "  ✅ Deployment Complete!"
    echo "========================================${NC}"
    echo ""
    echo -e "  ${BLUE}Access URL:${NC}   http://${SERVER_IP}:${APP_PORT}/"
    echo -e "  ${BLUE}Login:${NC}        admin / admin123"
    echo ""
    echo -e "  ${BLUE}Database:${NC}     ${DB_HOST}:${DB_PORT}/${DB_SERVICE}"
    echo ""
    echo -e "  ${YELLOW}Useful Commands:${NC}"
    echo "    View logs:     docker logs -f $APP_NAME"
    echo "    Restart:       docker restart $APP_NAME"
    echo "    Stop:          docker stop $APP_NAME"
    echo "    Start:         docker start $APP_NAME"
    echo "    Status:        docker ps --filter name=$APP_NAME"
    echo ""
    echo "========================================"
}

# =========================
# MAIN
# =========================

main() {
    print_banner
    check_root
    detect_os
    install_docker
    check_image_file
    load_docker_image
    stop_existing_container
    run_container
    configure_firewall
    wait_for_startup
    print_summary
}

main "$@"
