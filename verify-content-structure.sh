#!/bin/zsh
# Script to verify content structure and accessibility

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}      nForm Content Structure Verification     ${NC}"
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

# Step 1: Check content server
echo -e "\n${YELLOW}1. Checking content server...${NC}"
if ! check_content_server; then
  echo -e "${YELLOW}Content server is not running. Do you want to start it? (y/n)${NC}"
  read -r START_SERVER
  
  if [[ "$START_SERVER" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Starting content server...${NC}"
    node content-server.js > content-server.log 2>&1 &
    echo -e "${GREEN}Content server started with PID: $!${NC}"
    sleep 2 # Give server time to start
  else
    echo -e "${RED}Cannot continue verification without content server${NC}"
    exit 1
  fi
fi

# Step 2: Check directory structure
echo -e "\n${YELLOW}2. Checking directory structure...${NC}"
ISSUES=0

if [ ! -d "dist/md-content" ]; then
  echo -e "${RED}Missing directory: dist/md-content${NC}"
  ISSUES=1
else
  echo -e "${GREEN}Directory structure OK${NC}"
  
  # Show content files
  echo -e "${YELLOW}Found content files:${NC}"
  ls -la dist/md-content/*.json | head -5
  CONTENT_FILE_COUNT=$(ls -1 dist/md-content/*.json 2>/dev/null | wc -l)
  echo -e "${GREEN}Total content files: $CONTENT_FILE_COUNT${NC}"
fi

# Step 3: Check mapping file
echo -e "\n${YELLOW}3. Checking content mapping file...${NC}"
if [ ! -f "dist/nform-content-mapping.json" ]; then
  echo -e "${RED}Missing mapping file: dist/nform-content-mapping.json${NC}"
  ISSUES=1
else
  echo -e "${GREEN}Mapping file exists${NC}"
  MAPPING_ENTRIES=$(grep -o "md-content[^\"]*" dist/nform-content-mapping.json | wc -l)
  echo -e "${GREEN}Mapping entries: $MAPPING_ENTRIES${NC}"
fi

# Step 4: Check critical content files
echo -e "\n${YELLOW}4. Checking critical content files...${NC}"
FILES_TO_CHECK=(
  "md-contentquick-start262c9362fd2f6e2f.json"
  "md-contenthome5e8f84b66fd66837.json"
  "md-contentroot.json"
  "md-content/quick-start.json"
  "md-content/home.json"
)

for FILE in "${FILES_TO_CHECK[@]}"; do
  STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:4202/$FILE")
  if [ "$STATUS_CODE" -eq 200 ]; then
    echo -e "${GREEN}✓ $FILE is accessible (200 OK)${NC}"
    
    # Check for rich content
    if curl -s "http://localhost:4202/$FILE" | grep -q "pbl-app-content-chunk"; then
      echo -e "${GREEN}  ✓ Contains rich HTML content${NC}"
    else
      echo -e "${RED}  ✗ May contain placeholder content${NC}"
      ISSUES=1
    fi
  else
    echo -e "${RED}✗ $FILE is NOT accessible (Status: $STATUS_CODE)${NC}"
    ISSUES=1
  fi
done

# Step 5: Check source content files
echo -e "\n${YELLOW}5. Checking source content files...${NC}"
APPS_CONTENT_DIR="apps/nform-demo-app/src/md-content"
APPS_CONTENT_QUICK_START_DIR="apps/nform-demo-app/src/md-contentquick-start"

SOURCE_ISSUES=0

if [ -d "$APPS_CONTENT_DIR" ]; then
  echo -e "${GREEN}Source content directory exists: $APPS_CONTENT_DIR${NC}"
  
  # Check quick-start file
  if [ -f "$APPS_CONTENT_DIR/quick-start.json" ]; then
    if grep -q "pbl-app-content-chunk" "$APPS_CONTENT_DIR/quick-start.json"; then
      echo -e "${GREEN}✓ Source quick-start.json contains rich HTML content${NC}"
    else
      echo -e "${RED}✗ Source quick-start.json has placeholder content${NC}"
      SOURCE_ISSUES=1
    fi
  else
    echo -e "${RED}✗ Source quick-start.json file not found${NC}"
    SOURCE_ISSUES=1
  fi
else
  echo -e "${RED}✗ Source content directory not found: $APPS_CONTENT_DIR${NC}"
  SOURCE_ISSUES=1
fi

# Check specific quick-start file
if [ -d "$APPS_CONTENT_QUICK_START_DIR" ]; then
  echo -e "${GREEN}Quick-start content directory exists: $APPS_CONTENT_QUICK_START_DIR${NC}"
  
  if [ -f "$APPS_CONTENT_QUICK_START_DIR/262c9362fd2f6e2f.json" ]; then
    if grep -q "pbl-app-content-chunk" "$APPS_CONTENT_QUICK_START_DIR/262c9362fd2f6e2f.json"; then
      echo -e "${GREEN}✓ Source 262c9362fd2f6e2f.json contains rich HTML content${NC}"
    else
      echo -e "${RED}✗ Source 262c9362fd2f6e2f.json has placeholder content${NC}"
      SOURCE_ISSUES=1
    fi
  else
    echo -e "${RED}✗ Source 262c9362fd2f6e2f.json file not found${NC}"
    SOURCE_ISSUES=1
  fi
else
  echo -e "${RED}✗ Quick-start content directory not found: $APPS_CONTENT_QUICK_START_DIR${NC}"
  SOURCE_ISSUES=1
fi

if [ $SOURCE_ISSUES -eq 1 ]; then
  ISSUES=1
fi

# Step 6: Summary
echo -e "\n${YELLOW}6. Verification summary:${NC}"
if [ $ISSUES -eq 0 ]; then
  echo -e "${GREEN}===============================================${NC}"
  echo -e "${GREEN}     All content structure checks PASSED!     ${NC}"
  echo -e "${GREEN}===============================================${NC}"
  echo -e "\nYour content structure is correctly configured and all critical files are accessible."
else
  echo -e "${RED}===============================================${NC}"
  echo -e "${RED}     Content structure verification FAILED     ${NC}"
  echo -e "${RED}===============================================${NC}"
  echo -e "\nThere are issues with your content structure. Run the fix script to resolve them:"
  echo -e "${YELLOW}./fix-all-content-issues.sh${NC}"
fi
