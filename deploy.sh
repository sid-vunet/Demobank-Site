#!/bin/bash

# UCO Bank Finacle Deployment Script
# This script builds the WAR file, sets up Tomcat, deploys the app, and opens it in the browser

set -e

# Set JAVA_HOME for macOS (Homebrew OpenJDK)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [ -d "/opt/homebrew/opt/openjdk@11" ]; then
        export JAVA_HOME="/opt/homebrew/opt/openjdk@11"
    elif [ -d "/opt/homebrew/opt/openjdk" ]; then
        export JAVA_HOME="/opt/homebrew/opt/openjdk"
    elif [ -d "/usr/local/opt/openjdk@11" ]; then
        export JAVA_HOME="/usr/local/opt/openjdk@11"
    elif [ -d "/usr/local/opt/openjdk" ]; then
        export JAVA_HOME="/usr/local/opt/openjdk"
    fi
    export PATH="$JAVA_HOME/bin:$PATH"
fi

# Configuration
TOMCAT_VERSION="9.0.113"
TOMCAT_DIR="tomcat"
TOMCAT_DOWNLOAD_URL="https://dlcdn.apache.org/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
WEBAPP_DIR="java-webapp"
WAR_NAME="finacle.war"
APP_URL="http://localhost:8080/finacle/fininfra/ui/SSOLogin.jsp"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  UCO Bank Finacle Deployment Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to check if a command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}Error: $1 is not installed.${NC}"
        echo -e "${YELLOW}Please install $1 first.${NC}"
        exit 1
    fi
}

# Step 1: Check prerequisites
echo -e "${YELLOW}[1/6] Checking prerequisites...${NC}"
check_command java
check_command mvn
check_command curl

JAVA_VERSION=$(java -version 2>&1 | head -n 1)
echo -e "${GREEN}✓ Java found: ${JAVA_VERSION}${NC}"

MVN_VERSION=$(mvn -version 2>&1 | head -n 1)
echo -e "${GREEN}✓ Maven found: ${MVN_VERSION}${NC}"
echo ""

# Step 2: Build WAR file
echo -e "${YELLOW}[2/6] Building WAR file...${NC}"
cd "$WEBAPP_DIR"
mvn clean package -q
if [ -f "target/${WAR_NAME}" ]; then
    echo -e "${GREEN}✓ WAR file built successfully: target/${WAR_NAME}${NC}"
else
    echo -e "${RED}Error: WAR file not found after build${NC}"
    exit 1
fi
cd ..
echo ""

# Step 3: Download Tomcat if not present
echo -e "${YELLOW}[3/6] Setting up Tomcat...${NC}"
TOMCAT_HOME="${TOMCAT_DIR}/apache-tomcat-${TOMCAT_VERSION}"

if [ ! -d "$TOMCAT_HOME" ]; then
    echo "Downloading Apache Tomcat ${TOMCAT_VERSION}..."
    mkdir -p "$TOMCAT_DIR"
    
    # Try to download Tomcat
    TOMCAT_TAR="${TOMCAT_DIR}/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
    
    if curl -fSL "$TOMCAT_DOWNLOAD_URL" -o "$TOMCAT_TAR" 2>/dev/null; then
        echo "Extracting Tomcat..."
        tar -xzf "$TOMCAT_TAR" -C "$TOMCAT_DIR"
        rm "$TOMCAT_TAR"
        chmod +x "$TOMCAT_HOME/bin/"*.sh
        echo -e "${GREEN}✓ Tomcat ${TOMCAT_VERSION} installed${NC}"
    else
        echo -e "${RED}Error: Failed to download Tomcat from ${TOMCAT_DOWNLOAD_URL}${NC}"
        echo -e "${YELLOW}Please download Tomcat manually and extract to ${TOMCAT_DIR}/${NC}"
        echo -e "${YELLOW}Or try: brew install tomcat@9${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Tomcat already installed at ${TOMCAT_HOME}${NC}"
fi
echo ""

# Step 4: Stop Tomcat if running
echo -e "${YELLOW}[4/6] Stopping any running Tomcat instance...${NC}"
if [ -f "$TOMCAT_HOME/bin/shutdown.sh" ]; then
    "$TOMCAT_HOME/bin/shutdown.sh" 2>/dev/null || true
    sleep 2
fi
echo -e "${GREEN}✓ Tomcat stopped${NC}"
echo ""

# Step 5: Deploy WAR file
echo -e "${YELLOW}[5/6] Deploying WAR file...${NC}"

# Remove old deployment
rm -rf "$TOMCAT_HOME/webapps/finacle"
rm -f "$TOMCAT_HOME/webapps/finacle.war"

# Copy new WAR
cp "${WEBAPP_DIR}/target/${WAR_NAME}" "$TOMCAT_HOME/webapps/"
echo -e "${GREEN}✓ WAR file deployed to Tomcat${NC}"
echo ""

# Step 6: Start Tomcat and open browser
echo -e "${YELLOW}[6/6] Starting Tomcat...${NC}"
"$TOMCAT_HOME/bin/startup.sh"

echo ""
echo -e "${GREEN}Waiting for Tomcat to start...${NC}"
sleep 5

# Check if Tomcat is running
MAX_ATTEMPTS=30
ATTEMPT=0
while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080" | grep -q "200\|302\|404"; then
        echo -e "${GREEN}✓ Tomcat is running${NC}"
        break
    fi
    ATTEMPT=$((ATTEMPT + 1))
    echo "Waiting for Tomcat to be ready... (attempt $ATTEMPT/$MAX_ATTEMPTS)"
    sleep 1
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    echo -e "${RED}Warning: Tomcat may not have started properly${NC}"
    echo -e "${YELLOW}Check logs at: ${TOMCAT_HOME}/logs/catalina.out${NC}"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  Deployment Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Application URL: ${BLUE}${APP_URL}${NC}"
echo -e "Tomcat Manager: ${BLUE}http://localhost:8080/manager/html${NC}"
echo -e "Tomcat Logs: ${BLUE}${TOMCAT_HOME}/logs/catalina.out${NC}"
echo ""

# Open browser
echo -e "${YELLOW}Opening browser...${NC}"
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    open "$APP_URL"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    xdg-open "$APP_URL" 2>/dev/null || echo "Please open $APP_URL in your browser"
else
    echo "Please open $APP_URL in your browser"
fi

echo ""
echo -e "${GREEN}To stop Tomcat, run: ${TOMCAT_HOME}/bin/shutdown.sh${NC}"
echo -e "${GREEN}To view logs: tail -f ${TOMCAT_HOME}/logs/catalina.out${NC}"
