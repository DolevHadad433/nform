#!/bin/bash
# Test script for nForm content structure fix

# Text colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Testing nForm Content Structure Fix ===${NC}"

# 1. Check project.json
echo -e "${YELLOW}1. Checking project.json configuration...${NC}"
if grep -q "webpackConfig" "apps/nform-demo-app/project.json"; then
  echo -e "${RED}FAILED: project.json still contains deprecated webpackConfig property${NC}"
else
  echo -e "${GREEN}PASSED: project.json does not contain deprecated webpackConfig property${NC}"
fi

# 2. Check content files
echo -e "${YELLOW}2. Checking for content mapping files...${NC}"
if [ -f "dist/nform-content-mapping.json" ]; then
  echo -e "${GREEN}PASSED: Content mapping file exists${NC}"
else
  echo -e "${RED}FAILED: Content mapping file not found${NC}"
fi

if [ -d "dist/md-content" ]; then
  echo -e "${GREEN}PASSED: md-content directory exists${NC}"
else
  echo -e "${RED}FAILED: md-content directory not found${NC}"
fi

# 3. Check ContentMapService port
echo -e "${YELLOW}3. Checking ContentMapService configuration...${NC}"
if grep -q "contentServerUrl.*4202" "apps/libs/shared/lib/services/content-map.service.ts"; then
  echo -e "${GREEN}PASSED: ContentMapService is using port 4202${NC}"
else
  echo -e "${RED}FAILED: ContentMapService is not using port 4202${NC}"
fi

# 4. Check content server
echo -e "${YELLOW}4. Checking content server configuration...${NC}"
if grep -q "app.listen(4202" "content-server.js"; then
  echo -e "${GREEN}PASSED: Content server is configured for port 4202${NC}"
else
  echo -e "${RED}FAILED: Content server is not configured for port 4202${NC}"
fi

echo -e "${YELLOW}Test complete.${NC}"
