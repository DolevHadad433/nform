#!/bin/zsh
# Script to start the nForm app with advanced content verification

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}      nForm App Launcher with Advanced Content Check    ${NC}"
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

# Function to check content quality
check_content_quality() {
  local file_path=$1
  local content=$(curl -s "http://localhost:4202/${file_path}")
  
  if echo "$content" | grep -q "This is a placeholder"; then
    echo -e "${RED}Content file ${file_path} contains placeholder text${NC}"
    return 1
  else
    local title=$(echo "$content" | grep -o '"title"[^,]*' | head -n 1)
    echo -e "${GREEN}Content file ${file_path} has proper content with ${title}${NC}"
    return 0
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

# Step 2: Perform quality content verification
echo -e "\n${YELLOW}2. Verifying content quality...${NC}"
CONTENT_ISSUES=0

# Check key content files for placeholder text
if ! check_content_quality "md-contentquick-start/262c9362fd2f6e2f.json"; then
  CONTENT_ISSUES=1
fi

if ! check_content_quality "md-contentguide-intro/6024bf20223e39a0.json"; then
  CONTENT_ISSUES=1
fi

if ! check_content_quality "md-contentguide/basics/nform-basics/7084a93229fa485c.json"; then
  CONTENT_ISSUES=1
fi

# Step 3: Fix content issues if found
if [ $CONTENT_ISSUES -eq 1 ]; then
  echo -e "\n${YELLOW}Content quality issues detected. Do you want to run the comprehensive content generator? (y/n)${NC}"
  read -r RUN_FIX
  
  if [[ "$RUN_FIX" =~ ^[Yy]$ ]]; then
    echo -e "\n${YELLOW}Running comprehensive content generator...${NC}"
    ./run-comprehensive-content-generator.sh
  else
    echo -e "\n${YELLOW}Skipping content fix. Some content may display placeholder text.${NC}"
  fi
else
  echo -e "\n${GREEN}All checked content files have proper rich content!${NC}"
fi

# Step 4: Start the nForm app
echo -e "\n${YELLOW}3. Starting nForm application...${NC}"
echo -e "${BLUE}-----------------------------------------------${NC}"
yarn start
