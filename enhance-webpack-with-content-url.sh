#!/bin/zsh
# Enhanced script to optimize webpack configuration for content handling

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}    Enhanced Webpack Content URL Optimizer    ${NC}"
echo -e "${BLUE}===============================================${NC}"

# Step 1: Update webpack configuration to expose CONTENT_SERVER_URL
echo -e "\n${YELLOW}1. Optimizing webpack configuration...${NC}"

# Path to webpack config
WEBPACK_CONFIG="apps/nform-demo-app/build/webpack.config.ts"

# Check if the file exists
if [ ! -f "$WEBPACK_CONFIG" ]; then
  echo -e "${RED}Webpack config file not found at $WEBPACK_CONFIG${NC}"
  exit 1
fi

# Check if CONTENT_SERVER_URL is already correctly added to DefinePlugin
if grep -q "CONTENT_SERVER_URL: JSON.stringify(CONTENT_SERVER_URL)" "$WEBPACK_CONFIG"; then
  echo -e "${GREEN}CONTENT_SERVER_URL is already properly exposed in DefinePlugin${NC}"
else
  echo -e "${YELLOW}Adding CONTENT_SERVER_URL to DefinePlugin...${NC}"
  
  # Create a backup
  cp "$WEBPACK_CONFIG" "$WEBPACK_CONFIG.backup"
  
  # Use sed to add CONTENT_SERVER_URL to the return object in the async function
  sed -i '' '/return {/,/};/ s/BUILD_VERSION: JSON.stringify.*/BUILD_VERSION: JSON.stringify(gitInfo.latest ? gitInfo.latest.short_hash : '\''dev-build'\''),\n      CONTENT_SERVER_URL: JSON.stringify(CONTENT_SERVER_URL)/' "$WEBPACK_CONFIG"
  
  echo -e "${GREEN}Webpack config updated to expose CONTENT_SERVER_URL${NC}"
fi

# Step 2: Check and update ContentMapService
echo -e "\n${YELLOW}2. Checking ContentMapService implementation...${NC}"

# Path to ContentMapService
CONTENT_MAP_SERVICE="apps/libs/shared/lib/services/content-map.service.ts"

# Check if the file exists
if [ ! -f "$CONTENT_MAP_SERVICE" ]; then
  echo -e "${RED}ContentMapService file not found at $CONTENT_MAP_SERVICE${NC}"
  exit 1
fi

# Check if ContentMapService already declares the CONTENT_SERVER_URL constant
if grep -q "declare const CONTENT_SERVER_URL:" "$CONTENT_MAP_SERVICE"; then
  echo -e "${GREEN}ContentMapService already declares CONTENT_SERVER_URL constant${NC}"
else
  echo -e "${YELLOW}Adding CONTENT_SERVER_URL declaration to ContentMapService...${NC}"
  
  # Create a backup
  cp "$CONTENT_MAP_SERVICE" "$CONTENT_MAP_SERVICE.backup"
  
  # Add declaration after NFORM_CONTENT_MAPPING_FILE declaration
  sed -i '' '/declare const NFORM_CONTENT_MAPPING_FILE: string;/a\\
\
// Using fallback value if webpack doesn'\''t define it\
declare const CONTENT_SERVER_URL: string;' "$CONTENT_MAP_SERVICE"
  
  echo -e "${GREEN}Added CONTENT_SERVER_URL declaration to ContentMapService${NC}"
fi

# Check if ContentMapService uses webpack-provided CONTENT_SERVER_URL
if grep -q "typeof CONTENT_SERVER_URL !== 'undefined'" "$CONTENT_MAP_SERVICE"; then
  echo -e "${GREEN}ContentMapService already uses webpack-provided CONTENT_SERVER_URL${NC}"
else
  echo -e "${YELLOW}Updating ContentMapService to use webpack-provided CONTENT_SERVER_URL...${NC}"
  
  # Update the contentServerUrl property to use the webpack-provided URL
  sed -i '' 's/private contentServerUrl = this.isDevEnvironment ? '\''http:\/\/localhost:4202'\'' : '\'''\'';/private contentServerUrl = typeof CONTENT_SERVER_URL !== '\''undefined'\'' ? CONTENT_SERVER_URL : (this.isDevEnvironment ? '\''http:\/\/localhost:4202'\'' : '\'''\'');/' "$CONTENT_MAP_SERVICE"
  
  echo -e "${GREEN}Updated ContentMapService to use webpack-provided CONTENT_SERVER_URL${NC}"
fi

# Step 3: Run node-based optimization scripts
echo -e "\n${YELLOW}3. Running advanced optimizations...${NC}"

if [ -f "optimize-webpack-content-url.js" ]; then
  echo -e "${YELLOW}Running webpack content URL optimizer...${NC}"
  node optimize-webpack-content-url.js
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Webpack content URL optimization successful${NC}"
  else
    echo -e "${RED}Webpack content URL optimization failed${NC}"
  fi
fi

if [ -f "optimize-content-map-service.js" ]; then
  echo -e "${YELLOW}Running ContentMapService optimizer...${NC}"
  node optimize-content-map-service.js
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}ContentMapService optimization successful${NC}"
  else
    echo -e "${RED}ContentMapService optimization failed${NC}"
  fi
fi

# Step 4: Verify optimizations
echo -e "\n${YELLOW}4. Verifying optimizations...${NC}"

# Check webpack config
if grep -q "CONTENT_SERVER_URL: JSON.stringify" "$WEBPACK_CONFIG"; then
  echo -e "${GREEN}✓ Webpack config is properly exposing CONTENT_SERVER_URL${NC}"
else
  echo -e "${RED}✗ Webpack config is not properly exposing CONTENT_SERVER_URL${NC}"
fi

# Check ContentMapService declaration
if grep -q "declare const CONTENT_SERVER_URL:" "$CONTENT_MAP_SERVICE"; then
  echo -e "${GREEN}✓ ContentMapService declares CONTENT_SERVER_URL constant${NC}"
else
  echo -e "${RED}✗ ContentMapService is missing CONTENT_SERVER_URL declaration${NC}"
fi

# Check ContentMapService usage
if grep -q "typeof CONTENT_SERVER_URL !== 'undefined'" "$CONTENT_MAP_SERVICE"; then
  echo -e "${GREEN}✓ ContentMapService uses webpack-provided CONTENT_SERVER_URL${NC}"
else
  echo -e "${RED}✗ ContentMapService is not using webpack-provided CONTENT_SERVER_URL${NC}"
fi

echo -e "\n${BLUE}===============================================${NC}"
echo -e "${GREEN}     Webpack content URL optimization complete     ${NC}"
echo -e "${BLUE}===============================================${NC}"

echo -e "\n${YELLOW}Next steps:${NC}"
echo -e "1. Start the content server: ${GREEN}node content-server.js${NC}"
echo -e "2. Run the application with: ${GREEN}CONTENT_SERVER_URL=http://localhost:4202 yarn start${NC}"
echo -e "3. For production builds, use: ${GREEN}CONTENT_SERVER_URL=<your-prod-url> yarn build${NC}"
