#!/bin/zsh
# Script to generate rich content files and ensure content server is running

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Generating Rich Content Files ===${NC}"

# 1. Run the rich content generator
echo -e "${YELLOW}1. Generating rich content files...${NC}"
node generate-rich-content.js

# 2. Check if content server is running
echo -e "${YELLOW}2. Checking content server status...${NC}"
SERVER_PID=$(lsof -i:4202 -t || echo "")

if [ -n "$SERVER_PID" ]; then
    echo -e "${GREEN}Content server is already running on PID: $SERVER_PID${NC}"
    
    # Ask if user wants to restart the server
    echo -e "${YELLOW}Do you want to restart the content server? (y/n)${NC}"
    read -r RESTART_SERVER
    
    if [[ "$RESTART_SERVER" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Stopping existing content server...${NC}"
        kill -9 $SERVER_PID
        
        echo -e "${YELLOW}Starting content server...${NC}"
        node content-server.js > content-server.log 2>&1 &
        NEW_SERVER_PID=$!
        echo -e "${GREEN}Content server restarted with PID: $NEW_SERVER_PID${NC}"
    fi
else
    echo -e "${YELLOW}Content server is not running. Starting it now...${NC}"
    node content-server.js > content-server.log 2>&1 &
    NEW_SERVER_PID=$!
    echo -e "${GREEN}Content server started with PID: $NEW_SERVER_PID${NC}"
fi

# Wait for the server to start fully
echo -e "${YELLOW}Waiting for server to initialize...${NC}"
sleep 3

# 3. Verify content is accessible
echo -e "${YELLOW}3. Verifying content accessibility...${NC}"

# Check a few key files
echo -e "${YELLOW}Testing quick-start file...${NC}"
QUICK_START_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:4202/md-contentquick-start262c9362fd2f6e2f.json)
if [ "$QUICK_START_STATUS" -eq 200 ]; then
    echo -e "${GREEN}Quick Start file is accessible${NC}"
else
    echo -e "${RED}Quick Start file is NOT accessible (Status: $QUICK_START_STATUS)${NC}"
fi

echo -e "${YELLOW}Testing home file...${NC}"
HOME_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:4202/md-contenthome5e8f84b66fd66837.json)
if [ "$HOME_STATUS" -eq 200 ]; then
    echo -e "${GREEN}Home file is accessible${NC}"
else
    echo -e "${RED}Home file is NOT accessible (Status: $HOME_STATUS)${NC}"
fi

echo -e "${YELLOW}Testing root file...${NC}"
ROOT_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:4202/md-contentroot.json)
if [ "$ROOT_STATUS" -eq 200 ]; then
    echo -e "${GREEN}Root file is accessible${NC}"
else
    echo -e "${RED}Root file is NOT accessible (Status: $ROOT_STATUS)${NC}"
fi

echo -e "${GREEN}=== Content generation and verification completed ===${NC}"
echo -e "You can now run your main application with:"
echo -e "${YELLOW}yarn start${NC} or ${YELLOW}npm start${NC}"
