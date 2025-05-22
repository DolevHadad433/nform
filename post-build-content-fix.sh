#!/bin/zsh
# post-build-content-fix.sh
# This script should be run after the build process to ensure all content files are properly generated

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}      nForm Post-Build Content Fix            ${NC}"
echo -e "${BLUE}===============================================${NC}"

# Function to check if a command was successful
check_success() {
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}SUCCESS: $1${NC}"
  else
    echo -e "${RED}ERROR: $1${NC}"
    return 1
  fi
}

# 1. Check if the dist directory exists
echo -e "\n${YELLOW}1. Checking build output...${NC}"
if [ -d "dist" ]; then
  echo -e "${GREEN}Build output exists${NC}"
else
  echo -e "${RED}Build output not found. Run the build first.${NC}"
  exit 1
fi

# 2. Check if content files exist
echo -e "\n${YELLOW}2. Checking content files...${NC}"
if [ -d "dist/md-content" ]; then
  echo -e "${GREEN}Content directory exists${NC}"
else
  echo -e "${RED}Content directory not found. Running content generation...${NC}"
  ./generate-rich-content.sh
  check_success "Content generation" || exit 1
fi

# 3. Fix specific content files that have issues
echo -e "\n${YELLOW}3. Fixing specific content files...${NC}"

# Fix all content files using comprehensive generator
echo -e "${YELLOW}Running comprehensive content generator...${NC}"
./run-comprehensive-content-generator.sh
check_success "Comprehensive content generation" || exit 1

# 4. Verify the SSR processing script exists
echo -e "\n${YELLOW}4. Checking SSR processing script...${NC}"
if [ -f "dist/server.js" ]; then
  echo -e "${GREEN}SSR processing script exists${NC}"
else
  echo -e "${RED}SSR processing script not found${NC}"
  echo -e "${YELLOW}Checking if webpack build is needed...${NC}"
  
  if [ -f "apps/nform-demo-app/build/webpack.config.ssr.js" ]; then
    echo -e "${YELLOW}Running webpack build for SSR processing script...${NC}"
    NODE_ENV=production npx webpack --config apps/nform-demo-app/build/webpack.config.ssr.js
    check_success "Webpack build for SSR processing script" || exit 1
  else
    echo -e "${RED}Webpack config for SSR not found${NC}"
  fi
fi

# 5. Restart the content server to ensure it serves the latest files
echo -e "\n${YELLOW}5. Restarting content server...${NC}"
pkill -f "node content-server.js" 2>/dev/null || true
node content-server.js > content-server.log 2>&1 &
echo -e "${GREEN}Content server started with PID: $!${NC}"

# 6. Test content accessibility
echo -e "\n${YELLOW}6. Testing content accessibility...${NC}"
sleep 2 # Give server time to start

# Test Quick Start content
QUICK_START_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:4202/md-contentquick-start/262c9362fd2f6e2f.json)
if [ "$QUICK_START_STATUS" -eq 200 ]; then
  echo -e "${GREEN}Quick Start content is accessible${NC}"
else
  echo -e "${RED}Quick Start content is NOT accessible (Status: $QUICK_START_STATUS)${NC}"
fi

echo -e "\n${GREEN}=========================================${NC}"
echo -e "${GREEN}   Post-build content fix completed!      ${NC}"
echo -e "${GREEN}=========================================${NC}"
echo -e "\nYou can now access your application at:"
echo -e "${BLUE}http://localhost:4201${NC}"
