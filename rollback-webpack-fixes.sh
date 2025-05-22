#!/bin/zsh
# Script to roll back webpack content structure fixes if needed

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Rollback Webpack Content Structure Fixes ===${NC}"
echo "This script will restore the previous webpack configuration state."

# 1. Check for backup files
echo -e "${YELLOW}1. Checking for backup files...${NC}"
if [ -f "apps/nform-demo-app/build/webpack.config.ts.bak" ]; then
    echo "Found webpack.config.ts backup."
else
    echo -e "${RED}No webpack.config.ts backup found.${NC}"
    echo "Creating a backup of the current file before proceeding..."
    cp "apps/nform-demo-app/build/webpack.config.ts" "apps/nform-demo-app/build/webpack.config.ts.bak-$(date +%Y%m%d%H%M%S)"
fi

if [ -f "apps/nform-demo-app/project.json.bak" ]; then
    echo "Found project.json backup."
else
    echo -e "${RED}No project.json backup found.${NC}"
    echo "Creating a backup of the current file before proceeding..."
    cp "apps/nform-demo-app/project.json" "apps/nform-demo-app/project.json.bak-$(date +%Y%m%d%H%M%S)"
fi

# 2. Stop running servers
echo -e "${YELLOW}2. Stopping any running servers...${NC}"
CONTENT_SERVER_PID=$(lsof -i:4202 -t || echo "")
APP_SERVER_PID=$(lsof -i:4201 -t || echo "")

if [ -n "$CONTENT_SERVER_PID" ]; then
    echo "Stopping content server (PID: $CONTENT_SERVER_PID)"
    kill -9 $CONTENT_SERVER_PID 2>/dev/null
fi

if [ -n "$APP_SERVER_PID" ]; then
    echo "Stopping app server (PID: $APP_SERVER_PID)"
    kill -9 $APP_SERVER_PID 2>/dev/null
fi

# 3. Option to restore original webpackConfig in project.json
echo -e "${YELLOW}3. Would you like to restore the webpackConfig property to project.json? (y/n)${NC}"
read -r restore_webpack_config

if [[ "$restore_webpack_config" =~ ^[Yy]$ ]]; then
    echo "Restoring webpackConfig property in project.json..."
    sed -i '' '/allowedCommonJsDependencies/a \\
        "webpackConfig": "apps/nform-demo-app/build/webpack.content.js"' "apps/nform-demo-app/project.json"
    echo "✓ webpackConfig property restored"
fi

# 4. Clean up generated files
echo -e "${YELLOW}4. Cleaning up generated files...${NC}"
echo "Removing content files..."
rm -rf dist/md-content/*
rm -f dist/nform-content-mapping.json
echo "✓ Generated content files removed"

# 5. Clear Angular cache
echo -e "${YELLOW}5. Clearing Angular cache...${NC}"
rm -rf .angular/cache
echo "✓ Angular cache cleared"

echo -e "${GREEN}=== Rollback Complete ===${NC}"
echo "You can now restart with the original configuration."
echo "To restart with the original setup, run:"
echo "1. ./serve-with-direct-files.sh (for original setup)"
echo "2. ./fix-all-webpack-issues.sh (to reapply the fixes if needed)"
