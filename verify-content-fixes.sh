#!/bin/zsh
# Script to test that all content fixes have been applied successfully

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}     nForm Content Fix Verification Tool      ${NC}"
echo -e "${BLUE}===============================================${NC}"

# Step 1: Check webpack configuration
echo -e "\n${YELLOW}1. Checking webpack configuration...${NC}"
WEBPACK_CONFIG="apps/nform-demo-app/build/webpack.config.ts"

if [ ! -f "$WEBPACK_CONFIG" ]; then
  echo -e "${RED}Webpack config file not found!${NC}"
else
  # Check for CONTENT_SERVER_URL definition
  if grep -q "const CONTENT_SERVER_URL" "$WEBPACK_CONFIG"; then
    echo -e "${GREEN}✓ CONTENT_SERVER_URL is defined in webpack config${NC}"
  else
    echo -e "${RED}✗ CONTENT_SERVER_URL is not defined in webpack config${NC}"
  fi
  
  # Check for CONTENT_SERVER_URL in DefinePlugin
  if grep -q "CONTENT_SERVER_URL: JSON.stringify" "$WEBPACK_CONFIG"; then
    echo -e "${GREEN}✓ CONTENT_SERVER_URL is exposed via DefinePlugin${NC}"
  else
    echo -e "${RED}✗ CONTENT_SERVER_URL is not exposed via DefinePlugin${NC}"
  fi
fi

# Step 2: Check ContentMapService
echo -e "\n${YELLOW}2. Checking ContentMapService...${NC}"
CONTENT_SERVICE="apps/libs/shared/lib/services/content-map.service.ts"

if [ ! -f "$CONTENT_SERVICE" ]; then
  echo -e "${RED}ContentMapService file not found!${NC}"
else
  # Check for CONTENT_SERVER_URL declaration
  if grep -q "declare const CONTENT_SERVER_URL:" "$CONTENT_SERVICE"; then
    echo -e "${GREEN}✓ CONTENT_SERVER_URL is declared in ContentMapService${NC}"
  else
    echo -e "${RED}✗ CONTENT_SERVER_URL is not declared in ContentMapService${NC}"
  fi
  
  # Check for content server URL usage
  if grep -q "typeof CONTENT_SERVER_URL !== 'undefined'" "$CONTENT_SERVICE"; then
    echo -e "${GREEN}✓ ContentMapService uses webpack-provided CONTENT_SERVER_URL${NC}"
  else
    echo -e "${RED}✗ ContentMapService doesn't use webpack-provided CONTENT_SERVER_URL${NC}"
  fi
  
  # Check for proper transformPath implementation
  if grep -q "path.startsWith('md-content')" "$CONTENT_SERVICE"; then
    echo -e "${GREEN}✓ ContentMapService handles md-content paths${NC}"
  else
    echo -e "${RED}✗ ContentMapService doesn't handle md-content paths${NC}"
  fi
fi

# Step 3: Check content server
echo -e "\n${YELLOW}3. Checking content server...${NC}"
CONTENT_SERVER="content-server.js"

if [ ! -f "$CONTENT_SERVER" ]; then
  echo -e "${RED}Content server file not found!${NC}"
else
  # Check for correct routes
  if grep -q "app.get('/md-content" "$CONTENT_SERVER"; then
    echo -e "${GREEN}✓ Content server has proper md-content routes${NC}"
  else
    echo -e "${RED}✗ Content server is missing md-content routes${NC}"
  fi
  
  # Check if content server is running
  SERVER_PID=$(lsof -i:4202 -t 2>/dev/null || echo "")
  if [ -n "$SERVER_PID" ]; then
    echo -e "${GREEN}✓ Content server is running on PID: $SERVER_PID${NC}"
  else
    echo -e "${RED}✗ Content server is not running${NC}"
    
    # Ask if user wants to start the server
    echo -e "${YELLOW}Do you want to start the content server? (y/n)${NC}"
    read -r START_SERVER
    
    if [[ "$START_SERVER" =~ ^[Yy]$ ]]; then
      echo -e "${YELLOW}Starting content server...${NC}"
      node "$CONTENT_SERVER" > content-server.log 2>&1 &
      SERVER_PID=$!
      echo -e "${GREEN}Content server started with PID: $SERVER_PID${NC}"
    fi
  fi
fi

# Step 4: Check content files
echo -e "\n${YELLOW}4. Checking content files...${NC}"

# Function to check if a file exists
check_file() {
  if [ -f "$1" ]; then
    echo -e "${GREEN}✓ $2 exists${NC}"
    return 0
  else
    echo -e "${RED}✗ $2 is missing${NC}"
    return 1
  fi
}

# Check mapping file
check_file "dist/nform-content-mapping.json" "Content mapping file"

# Check important content files
check_file "dist/md-content/quick-start.json" "Quick start content file"
check_file "dist/md-contentquick-start262c9362fd2f6e2f.json" "Quick start direct access file"
check_file "dist/md-content/home.json" "Home content file"
check_file "dist/md-contenthome5e8f84b66fd66837.json" "Home direct access file"

# Step 5: Check content file accessibility
echo -e "\n${YELLOW}5. Checking content accessibility...${NC}"

if [ -n "$SERVER_PID" ]; then
  # Function to check if a URL is accessible
  check_url() {
    STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$1")
    if [ "$STATUS_CODE" -eq 200 ]; then
      echo -e "${GREEN}✓ $2 is accessible (HTTP 200)${NC}"
      return 0
    else
      echo -e "${RED}✗ $2 is not accessible (HTTP $STATUS_CODE)${NC}"
      return 1
    fi
  }
  
  # Check important URLs
  check_url "http://localhost:4202/nform-content-mapping.json" "Content mapping file"
  check_url "http://localhost:4202/md-content/quick-start.json" "Quick start content with slashes"
  check_url "http://localhost:4202/md-contentquick-start262c9362fd2f6e2f.json" "Quick start content without slashes"
  check_url "http://localhost:4202/md-contenthome5e8f84b66fd66837.json" "Home content without slashes"
else
  echo -e "${YELLOW}Skipping content accessibility checks because content server is not running${NC}"
fi

echo -e "\n${BLUE}===============================================${NC}"
echo -e "${GREEN}     Content fix verification completed     ${NC}"
echo -e "${BLUE}===============================================${NC}"

echo -e "\n${YELLOW}Next steps:${NC}"
echo -e "1. If you found any issues, run: ${GREEN}./enhance-webpack-with-content-url.sh${NC}"
echo -e "2. If content files are missing, run: ${GREEN}./generate-rich-content.sh${NC}"
echo -e "3. Start your application with: ${GREEN}CONTENT_SERVER_URL=http://localhost:4202 yarn start${NC}"
