#!/bin/zsh
# Script to optimize webpack configuration for content handling

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}     Webpack Content URL Optimization Tool     ${NC}"
echo -e "${BLUE}===============================================${NC}"

# Step 1: Update webpack config to expose CONTENT_SERVER_URL
echo -e "\n${YELLOW}1. Optimizing webpack config to expose content server URL...${NC}"
node optimize-webpack-content-url.js

# Step 2: Update ContentMapService to use CONTENT_SERVER_URL from webpack
echo -e "\n${YELLOW}2. Checking ContentMapService implementation...${NC}"

# Path to ContentMapService
CONTENT_MAP_SERVICE_PATH="apps/libs/shared/lib/services/content-map.service.ts"

# Check if ContentMapService is correctly declaring the CONTENT_SERVER_URL constant
if grep -q "declare const CONTENT_SERVER_URL: string;" "$CONTENT_MAP_SERVICE_PATH"; then
  echo -e "${GREEN}ContentMapService is already configured to use CONTENT_SERVER_URL from webpack${NC}"
else
  echo -e "${YELLOW}Updating ContentMapService to use CONTENT_SERVER_URL from webpack...${NC}"
  
  # Create a temporary file with the updated content
  sed '/declare const NFORM_CONTENT_MAPPING_FILE: string;/a \
// Using fallback value if webpack doesn\x27t define it\
declare const CONTENT_SERVER_URL: string;' "$CONTENT_MAP_SERVICE_PATH" > content-map-service.tmp
  
  # Replace contentServerUrl initialization to use the webpack-provided value
  sed -i '' 's/private contentServerUrl = this.isDevEnvironment ? '\''http:\/\/localhost:4202'\'' : '\'''\'';/private contentServerUrl = typeof CONTENT_SERVER_URL !== '\''undefined'\'' ? CONTENT_SERVER_URL : (this.isDevEnvironment ? '\''http:\/\/localhost:4202'\'' : '\'''\'');/' content-map-service.tmp
  
  # Move the temporary file to replace the original
  mv content-map-service.tmp "$CONTENT_MAP_SERVICE_PATH"
  
  echo -e "${GREEN}ContentMapService updated successfully!${NC}"
fi

# Step 3: Verify all changes
echo -e "\n${YELLOW}3. Verifying changes...${NC}"

# Check webpack config for CONTENT_SERVER_URL in DefinePlugin
if grep -q "CONTENT_SERVER_URL: JSON.stringify" "apps/nform-demo-app/build/webpack.config.ts"; then
  echo -e "${GREEN}✓ Webpack config is properly exposing CONTENT_SERVER_URL${NC}"
else
  echo -e "${RED}✗ Webpack config is not properly exposing CONTENT_SERVER_URL${NC}"
fi

# Check ContentMapService for proper handling
if grep -q "typeof CONTENT_SERVER_URL !== 'undefined'" "$CONTENT_MAP_SERVICE_PATH"; then
  echo -e "${GREEN}✓ ContentMapService is properly using CONTENT_SERVER_URL${NC}"
else
  echo -e "${RED}✗ ContentMapService is not properly using CONTENT_SERVER_URL${NC}"
fi

echo -e "\n${GREEN}Optimization completed!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Restart your development server with: ${GREEN}./restart-dev-server-with-content.sh${NC}"
echo -e "2. Build your application with: ${GREEN}./build-with-fixed-content.sh${NC}"
echo -e "3. Test content access with: ${GREEN}./verify-content-structure.sh${NC}"
