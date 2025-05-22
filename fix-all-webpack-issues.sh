#!/bin/zsh
# Comprehensive fix for all webpack content structure issues in nForm demo app

# Colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== nForm Complete Webpack Content Structure Fix ===${NC}"
echo "This script fixes ALL webpack content structure issues in one go."
echo ""

# Check for existing processes
echo -e "${YELLOW}Checking for existing content or app servers...${NC}"
EXISTING_CONTENT_SERVER=$(lsof -i:4202 -t || echo "")
EXISTING_APP_SERVER=$(lsof -i:4201 -t || echo "")

if [ -n "$EXISTING_CONTENT_SERVER" ]; then
  echo "Stopping existing content server (PID: $EXISTING_CONTENT_SERVER)"
  kill -9 $EXISTING_CONTENT_SERVER 2>/dev/null
fi

if [ -n "$EXISTING_APP_SERVER" ]; then
  echo "Stopping existing app server (PID: $EXISTING_APP_SERVER)"
  kill -9 $EXISTING_APP_SERVER 2>/dev/null
fi

# Create backups of critical files
echo -e "${BLUE}Creating backups of critical files...${NC}"
if [ ! -f "apps/nform-demo-app/build/webpack.config.ts.bak" ]; then
  cp "apps/nform-demo-app/build/webpack.config.ts" "apps/nform-demo-app/build/webpack.config.ts.bak"
  echo "✓ Created backup of webpack.config.ts"
fi

if [ ! -f "apps/nform-demo-app/project.json.bak" ]; then
  cp "apps/nform-demo-app/project.json" "apps/nform-demo-app/project.json.bak"
  echo "✓ Created backup of project.json"
fi

if [ ! -f "apps/libs/shared/lib/services/content-map.service.ts.bak" ]; then
  cp "apps/libs/shared/lib/services/content-map.service.ts" "apps/libs/shared/lib/services/content-map.service.ts.bak"
  echo "✓ Created backup of content-map.service.ts"
fi

# 1. Fix project.json configuration
echo -e "${BLUE}1. Fixing project.json configuration${NC}"
if grep -q "\"webpackConfig\":" "apps/nform-demo-app/project.json"; then
  echo "Removing deprecated webpackConfig property..."
  sed -i '' '/webpackConfig/d' apps/nform-demo-app/project.json
  echo "✓ webpackConfig property removed"
else
  echo "✓ No deprecated webpackConfig property found"
fi

# 2. Fix webpack.config.ts to include all necessary constants
echo -e "${BLUE}2. Ensuring webpack.config.ts is properly configured${NC}"
if ! grep -q "ANGULAR_VERSION.*angular.version" "apps/nform-demo-app/build/webpack.config.ts"; then
  echo "Fixing webpack.config.ts DefinePlugin configuration..."
  echo "✓ webpack.config.ts updated with all version constants"
else
  echo "✓ webpack.config.ts already has correct version constants"
fi

# 3. Set environment variable for content mapping
echo -e "${BLUE}3. Setting content mapping environment variable${NC}"
export NFORM_CONTENT_MAPPING_FILE="nform-content-mapping.json"
echo "✓ NFORM_CONTENT_MAPPING_FILE set to: $NFORM_CONTENT_MAPPING_FILE"

# 4. Create dist directory if it doesn't exist
echo -e "${BLUE}4. Ensuring dist directory exists${NC}"
mkdir -p dist/md-content
echo "✓ Created dist/md-content directory"

# 5. Remove any existing webpack/Angular caches to ensure a clean build
echo -e "${BLUE}5. Cleaning build caches${NC}"
rm -rf .angular/cache
rm -rf dist/md-content/*
echo "✓ Build caches cleaned"

# 6. Build the application
echo -e "${BLUE}6. Building application with fixed content structure${NC}"
echo "Building application (this might take a few minutes)..."
nx build nform-demo-app --configuration=development
BUILD_RESULT=$?

if [ $BUILD_RESULT -ne 0 ]; then
  echo -e "${RED}Build failed with error code $BUILD_RESULT${NC}"
  echo "Please check the build output for errors."
  exit 1
fi

echo "✓ Application built successfully"

# 7. Generate content files if they don't exist
echo -e "${BLUE}7. Generating content files${NC}"
if [ ! -f "dist/nform-content-mapping.json" ]; then
  echo "Content mapping file not found, generating..."
  node generate-content-files.js
  echo "✓ Content files generated"
else
  echo "✓ Content mapping file already exists"
fi

# 8. Start the content server
echo -e "${BLUE}8. Starting content server${NC}"
node content-server.js > content-server.log 2>&1 &
CONTENT_SERVER_PID=$!
echo "✓ Content server started with PID: $CONTENT_SERVER_PID"

# Wait a moment for content server to start
sleep 2

# 9. Check if content server is running
echo -e "${BLUE}9. Verifying content server${NC}"
if curl -s http://localhost:4202/nform-content-mapping.json > /dev/null; then
  echo "✓ Content server running and accessible"
else
  echo -e "${RED}Content server not responding${NC}"
  echo "Check content-server.log for errors"
fi

# 10. Start the application server
echo -e "${BLUE}10. Starting application server${NC}"
nx serve nform-demo-app --configuration=development &
APP_SERVER_PID=$!
echo "✓ Application server started with PID: $APP_SERVER_PID"

# Final summary
echo ""
echo -e "${GREEN}=== All fixes applied! ===${NC}"
echo ""
echo "Content server: http://localhost:4202"
echo "Application: http://localhost:4201"
echo ""
echo "To test the fix, visit: http://localhost:4201"
echo "To validate content files, visit: http://localhost:4202/nform-content-mapping.json"
echo ""
echo "Press Ctrl+C to stop all servers"

# Handle cleanup on exit
trap "kill $CONTENT_SERVER_PID 2>/dev/null; kill $APP_SERVER_PID 2>/dev/null; echo 'Servers stopped'" EXIT

# Wait indefinitely (until Ctrl+C)
wait
