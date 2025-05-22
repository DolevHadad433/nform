#!/bin/zsh
# Script to start the nForm app with automatic content verification

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}      nForm App Launcher with Content Check    ${NC}"
echo -e "${BLUE}===============================================${NC}"

# Function to check if content server is running
check_content_server() {
  SERVER_PID=$(lsof -i:4202 -t 2>/dev/null || echo "")
  if [ -n "$SERVER_PID" ]; then
    echo -e "${GREEN}Content server is running on PID: $SERVER_PID${NC}"
    return 0
  else
    echo -e "${RED}Content server is not running${NC}"
    return 1
  fi
}

# Function to check if a content file is accessible
check_content_file() {
  local file_path=$1
  local status_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:4202/${file_path}")
  
  if [ "$status_code" -eq 200 ]; then
    echo -e "${GREEN}Content file ${file_path} is accessible${NC}"
    return 0
  else
    echo -e "${RED}Content file ${file_path} is NOT accessible (Status: ${status_code})${NC}"
    return 1
  fi
}

# Step 1: Check content server
echo -e "\n${YELLOW}1. Checking content server...${NC}"
if ! check_content_server; then
  echo -e "${YELLOW}Starting content server...${NC}"
  node content-server.js > content-server.log 2>&1 &
  echo -e "${GREEN}Content server started with PID: $!${NC}"
  sleep 2 # Give server time to start
fi

# Step 2: Perform quick content verification
echo -e "\n${YELLOW}2. Verifying content files...${NC}"
CONTENT_ISSUES=0

# Check key content files
if ! check_content_file "md-contentquick-start262c9362fd2f6e2f.json"; then
  CONTENT_ISSUES=1
fi

if ! check_content_file "md-contenthome5e8f84b66fd66837.json"; then
  CONTENT_ISSUES=1
fi

# Step 3: Fix content issues if found
if [ $CONTENT_ISSUES -eq 1 ]; then
  echo -e "\n${YELLOW}Content issues detected. Do you want to run the content fix script? (y/n)${NC}"
  read -r RUN_FIX
  
  if [[ "$RUN_FIX" =~ ^[Yy]$ ]]; then
    echo -e "\n${YELLOW}Running content fix script...${NC}"
    ./generate-rich-content.sh
  else
    echo -e "\n${YELLOW}Skipping content fix. Some content may not display correctly.${NC}"
  fi
else
  echo -e "\n${GREEN}All content files are accessible!${NC}"
fi

# Step 4: Start the nForm app
echo -e "\n${YELLOW}3. Starting nForm application...${NC}"
echo -e "${BLUE}-----------------------------------------------${NC}"
yarn start
