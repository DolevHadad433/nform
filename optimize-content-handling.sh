#!/bin/zsh
# Script to apply optimized content handling updates

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}   nForm Content Handling Optimization Tool   ${NC}"
echo -e "${BLUE}===============================================${NC}"

# Apply webpack URL configuration updates
echo -e "\n${YELLOW}1. Applying webpack content server URL configurations...${NC}"
node update-content-server-url.js

# Optimize ContentMapService
echo -e "\n${YELLOW}2. Optimizing ContentMapService path handling...${NC}"
node optimize-content-map-service.js

# Generate rich content
echo -e "\n${YELLOW}3. Regenerating content files with rich content...${NC}"
./generate-rich-content.sh

# Verify content accessibility
echo -e "\n${YELLOW}4. Verifying content access patterns...${NC}"
echo -e "${YELLOW}Testing standard paths with slashes...${NC}"
curl -s -o /dev/null -w "md-content/quick-start.json: %{http_code}\n" http://localhost:4202/md-content/quick-start.json
curl -s -o /dev/null -w "md-content/home.json: %{http_code}\n" http://localhost:4202/md-content/home.json

echo -e "${YELLOW}Testing paths without slashes but with IDs...${NC}"
curl -s -o /dev/null -w "md-contentquick-start262c9362fd2f6e2f.json: %{http_code}\n" http://localhost:4202/md-contentquick-start262c9362fd2f6e2f.json
curl -s -o /dev/null -w "md-contenthome5e8f84b66fd66837.json: %{http_code}\n" http://localhost:4202/md-contenthome5e8f84b66fd66837.json

echo -e "${YELLOW}Testing the previously problematic file pattern...${NC}"
curl -s -o /dev/null -w "md-content5e8f84b66fd66837.json: %{http_code}\n" http://localhost:4202/md-content5e8f84b66fd66837.json

# Create documentation
echo -e "\n${YELLOW}5. Updating documentation...${NC}"
QUICK_DOC_PATH="CONTENT_PATTERN_GUIDE.md"
cat > "${QUICK_DOC_PATH}" << 'EOL'
# nForm Content Pattern Guide

## Content Path Patterns

nForm supports the following content path patterns:

1. **Standard path with slashes**: `md-content/file.json` 
   - Example: `md-content/quick-start.json`

2. **Path without slashes but with IDs**: `md-contentfileID.json`
   - Example: `md-contentquick-start262c9362fd2f6e2f.json`

3. **Simple path without slashes**: `md-contentfile.json`
   - Example: `md-contentquick-start.json`

4. **Direct ID path**: `md-contentID.json`
   - Example: `md-content5e8f84b66fd66837.json`

## Content Server URL Configuration

The content server URL can be configured through:

1. Environment variable: `CONTENT_SERVER_URL`
2. Default in webpack config: `http://localhost:4202`

## Troubleshooting

If you encounter 404 errors for content files:

1. Run `./optimize-content-handling.sh` to apply all optimizations
2. Ensure the content server is running: `node content-server.js`
3. Verify content accessibility: `curl http://localhost:4202/md-content/your-file.json`

For more detailed information, see the comprehensive guide at `docs/NFORM_CONTENT_COMPREHENSIVE_GUIDE.md`.
EOL

echo -e "${GREEN}Quick reference guide created at: ${QUICK_DOC_PATH}${NC}"

echo -e "\n${GREEN}==========================================${NC}"
echo -e "${GREEN}   Content handling optimizations complete!  ${NC}"
echo -e "${GREEN}==========================================${NC}"
echo -e "\nYou can now start your application with:"
echo -e "${YELLOW}./start-app-with-content-check.sh${NC}"
