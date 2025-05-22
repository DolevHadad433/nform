#!/bin/zsh
# complete-build-with-content.sh
# This script performs a complete build process with all content fixes

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}      nForm Complete Build with Content Fixes  ${NC}"
echo -e "${BLUE}===============================================${NC}"

# Function to check if a command was successful
check_success() {
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}SUCCESS: $1${NC}"
  else
    echo -e "${RED}ERROR: $1${NC}"
    exit 1
  fi
}

# 1. Build the application
echo -e "\n${YELLOW}1. Building the application...${NC}"
npx nx build nform-demo-app
check_success "Application build"

# 2. Build the server
echo -e "\n${YELLOW}2. Building the server...${NC}"
npx nx run nform-demo-app:server:production
check_success "Server build"

# 3. Build the SSR processing script
echo -e "\n${YELLOW}3. Building the SSR processing script...${NC}"
NODE_ENV=production npx webpack --config apps/nform-demo-app/build/webpack.config.ssr.js
check_success "SSR processing script build"

# 4. Apply content fixes
echo -e "\n${YELLOW}4. Applying content fixes...${NC}"
./run-comprehensive-content-generator.sh
check_success "Comprehensive content generation"

# 5. Start the content server and application server
echo -e "\n${YELLOW}5. Starting servers...${NC}"

# Ask if user wants to start the content server
echo -e "${YELLOW}Do you want to start the content server? (y/n)${NC}"
read -r START_CONTENT_SERVER

if [[ "$START_CONTENT_SERVER" =~ ^[Yy]$ ]]; then
  echo -e "${YELLOW}Starting content server...${NC}"
  pkill -f "node content-server.js" 2>/dev/null || true
  node content-server.js > content-server.log 2>&1 &
  CONTENT_SERVER_PID=$!
  echo -e "${GREEN}Content server started with PID: $CONTENT_SERVER_PID${NC}"
fi

# Ask if user wants to start the application server
echo -e "${YELLOW}Do you want to start the application server? (y/n)${NC}"
read -r START_APP_SERVER

if [[ "$START_APP_SERVER" =~ ^[Yy]$ ]]; then
  echo -e "${YELLOW}Starting application server...${NC}"
  npx nx serve nform-demo-app
else
  echo -e "${YELLOW}To start the application server manually, run:${NC}"
  echo -e "${BLUE}npx nx serve nform-demo-app${NC}"
fi

echo -e "\n${GREEN}=========================================${NC}"
echo -e "${GREEN}   Complete build with content fixes done! ${NC}"
echo -e "${GREEN}=========================================${NC}"
