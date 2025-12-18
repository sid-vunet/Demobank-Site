#!/bin/bash

# UCO Bank Finacle - Stop Tomcat Script

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

TOMCAT_VERSION="9.0.113"
TOMCAT_HOME="tomcat/apache-tomcat-${TOMCAT_VERSION}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "Stopping Tomcat..."

if [ -f "$TOMCAT_HOME/bin/shutdown.sh" ]; then
    "$TOMCAT_HOME/bin/shutdown.sh"
    echo -e "${GREEN}✓ Tomcat shutdown signal sent${NC}"
    echo "Waiting for Tomcat to stop..."
    sleep 3
    
    # Force kill if still running
    TOMCAT_PID=$(ps aux | grep "[c]atalina" | awk '{print $2}')
    if [ -n "$TOMCAT_PID" ]; then
        echo "Force stopping Tomcat (PID: $TOMCAT_PID)..."
        kill -9 $TOMCAT_PID 2>/dev/null || true
    fi
    
    echo -e "${GREEN}✓ Tomcat stopped${NC}"
else
    echo -e "${RED}Tomcat not found at ${TOMCAT_HOME}${NC}"
    echo "Looking for running Tomcat processes..."
    TOMCAT_PID=$(ps aux | grep "[c]atalina" | awk '{print $2}')
    if [ -n "$TOMCAT_PID" ]; then
        echo "Killing Tomcat process (PID: $TOMCAT_PID)..."
        kill -9 $TOMCAT_PID
        echo -e "${GREEN}✓ Tomcat process killed${NC}"
    else
        echo "No Tomcat process found running"
    fi
fi
