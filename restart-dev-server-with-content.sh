#!/bin/zsh
# Restart development server with proper content handling

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}     nForm Development Server Restart Tool     ${NC}"
echo -e "${BLUE}===============================================${NC}"

# Step 1: Optimize webpack configuration
echo -e "\n${YELLOW}1. Applying webpack content optimizations...${NC}"
chmod +x ./optimize-webpack-content.sh
./optimize-webpack-content.sh

# Step 2: Generate rich content if needed
echo -e "\n${YELLOW}2. Checking if rich content needs to be generated...${NC}"

# Check if a key content file exists
if [ ! -f "dist/md-contentquick-start262c9362fd2f6e2f.json" ]; then
  echo -e "${YELLOW}Missing content files detected. Generating rich content...${NC}"
  chmod +x ./generate-rich-content.sh
  ./generate-rich-content.sh
else
  echo -e "${GREEN}Content files already exist${NC}"
  
  # Check if content server is running
  SERVER_PID=$(lsof -i:4202 -t 2>/dev/null || echo "")
  if [ -z "$SERVER_PID" ]; then
    echo -e "${YELLOW}Content server is not running. Starting it...${NC}"
    node content-server.js > content-server.log 2>&1 &
    echo -e "${GREEN}Content server started with PID: $!${NC}"
  else
    echo -e "${GREEN}Content server already running with PID: $SERVER_PID${NC}"
  fi
fi

# Step 3: Stop existing development server if running
echo -e "\n${YELLOW}3. Checking for running development server...${NC}"
DEV_SERVER_PID=$(lsof -i:4201 -t 2>/dev/null || echo "")
if [ -n "$DEV_SERVER_PID" ]; then
  echo -e "${YELLOW}Stopping existing development server (PID: $DEV_SERVER_PID)...${NC}"
  kill -9 $DEV_SERVER_PID
  sleep 2
fi

# Step 4: Start development server with content server URL
echo -e "\n${YELLOW}4. Starting development server with content server URL...${NC}"
echo -e "${BLUE}-----------------------------------------------${NC}"
CONTENT_SERVER_URL=http://localhost:4202 nx serve nform-demo-app --serve-path="/" --liveReload=true

# This command will block until the server exits
echo -e "\n${RED}Development server stopped${NC}"
