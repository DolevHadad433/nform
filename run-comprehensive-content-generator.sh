#!/bin/zsh
# Script to run the comprehensive content generator and restart the content server

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Running Comprehensive Content Generator ===${NC}"

# 1. Run the content generator
echo -e "${YELLOW}1. Generating comprehensive content files...${NC}"
node comprehensive-content-generator.js

# 2. Restart the content server
echo -e "${YELLOW}2. Restarting content server...${NC}"

# Check if content server is running
SERVER_PID=$(lsof -i:4202 -t 2>/dev/null || echo "")

if [ -n "$SERVER_PID" ]; then
    echo -e "${YELLOW}Stopping existing content server...${NC}"
    kill -9 $SERVER_PID 2>/dev/null || true
fi

echo -e "${YELLOW}Starting content server...${NC}"
node content-server.js > content-server.log 2>&1 &
NEW_SERVER_PID=$!
echo -e "${GREEN}Content server started with PID: $NEW_SERVER_PID${NC}"

# Wait for the server to start fully
echo -e "${YELLOW}Waiting for server to initialize...${NC}"
sleep 3

# 3. Verify key content files
echo -e "${YELLOW}3. Verifying content accessibility...${NC}"

# Define files to test
TEST_FILES=(
    "md-contentquick-start/262c9362fd2f6e2f.json"
    "md-contentguide-intro/6024bf20223e39a0.json"
    "md-contentguide/basics/nform-basics/7084a93229fa485c.json"
)

for file in "${TEST_FILES[@]}"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:4202/$file")
    if [ "$STATUS" -eq 200 ]; then
        echo -e "${GREEN}✓ $file is accessible${NC}"
        
        # Print content snippet
        CONTENT=$(curl -s "http://localhost:4202/$file" | grep -o '"contents": ".*"' | head -c 100)
        echo -e "  Content: ${CONTENT}..."
    else
        echo -e "${RED}✗ $file is NOT accessible (Status: $STATUS)${NC}"
    fi
done

echo -e "${GREEN}=== Content generation and verification completed ===${NC}"
echo -e "${GREEN}You can now run your main application with:${NC}"
echo -e "${YELLOW}yarn start${NC} or ${YELLOW}npm start${NC}"
