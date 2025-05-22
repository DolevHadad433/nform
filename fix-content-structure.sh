#!/bin/bash
# Comprehensive fix for nForm webpack content structure issues

# Text colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== nForm Content Structure Fix ===${NC}"
echo "This script fixes webpack content structure issues in the nForm demo app."

# 1. Fix project.json to use the proper webpack config
echo -e "${YELLOW}1. Checking project.json configuration...${NC}"
if grep -q "webpackConfig" "apps/nform-demo-app/project.json"; then
  echo "Removing deprecated webpackConfig property from project.json"
  # Use sed to remove the webpackConfig line (platform-independent)
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS version
    sed -i '' '/webpackConfig/d' apps/nform-demo-app/project.json
  else
    # Linux version
    sed -i '/webpackConfig/d' apps/nform-demo-app/project.json
  fi
else
  echo "No deprecated webpackConfig property found in project.json"
fi

# 2. Ensure the content mapping file is properly referenced
echo -e "${YELLOW}2. Setting up content mapping environment...${NC}"
export NFORM_CONTENT_MAPPING_FILE=nform-content-mapping.json
echo "Set NFORM_CONTENT_MAPPING_FILE to: $NFORM_CONTENT_MAPPING_FILE"

# 3. Build with the custom webpack configuration
echo -e "${YELLOW}3. Building the application with fixed content structure...${NC}"
echo "Running build with content structure fixes..."

# Use nx to build with the custom webpack config
nx build nform-demo-app --configuration=development

# 4. Start the content server
echo -e "${YELLOW}4. Starting the content server...${NC}"
node content-server.js &
CONTENT_SERVER_PID=$!
echo "Content server started with PID: $CONTENT_SERVER_PID"

# 5. Start the application
echo -e "${YELLOW}5. Starting the application...${NC}"
nx serve nform-demo-app --configuration=development &
APP_SERVER_PID=$!
echo "Application server started with PID: $APP_SERVER_PID"

echo -e "${GREEN}=== Setup Complete ===${NC}"
echo "Content server running on: http://localhost:4202"
echo "Application running on: http://localhost:4201"
echo ""
echo "Press Ctrl+C to stop all servers"

# Handle cleanup when the script is interrupted
function cleanup {
  echo -e "${YELLOW}Stopping servers...${NC}"
  kill $CONTENT_SERVER_PID 2>/dev/null
  kill $APP_SERVER_PID 2>/dev/null
  echo "Servers stopped"
  exit 0
}

trap cleanup SIGINT

# Wait for the user to press Ctrl+C
wait
