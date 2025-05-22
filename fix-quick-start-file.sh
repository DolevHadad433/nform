#!/bin/zsh
# Script to fix and validate specific content file issues

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Fixing Specific Content File Issue ===${NC}"

# 1. Check if the problematic file exists
SPECIFIC_FILE="262c9362fd2f6e2f.json"
DIST_DIR="dist"
CONTENT_DIR="${DIST_DIR}/md-content"

echo -e "${YELLOW}Checking for file: ${SPECIFIC_FILE}${NC}"

if [ -f "${CONTENT_DIR}/${SPECIFIC_FILE}" ]; then
    echo -e "${GREEN}File exists at: ${CONTENT_DIR}/${SPECIFIC_FILE}${NC}"
else
    echo -e "${RED}File not found at: ${CONTENT_DIR}/${SPECIFIC_FILE}${NC}"
    
    # Create the file if it doesn't exist
    echo -e "${YELLOW}Creating file...${NC}"
    mkdir -p "${CONTENT_DIR}"
    
    # Create a simple JSON content file
    cat > "${CONTENT_DIR}/${SPECIFIC_FILE}" << EOL
{
  "title": "Quick Start",
  "html": "<h1>This content was generated to fix 404 errors</h1><p>This file was missing from the content structure.</p>"
}
EOL
    
    echo -e "${GREEN}Created file at: ${CONTENT_DIR}/${SPECIFIC_FILE}${NC}"
fi

# 2. Create a symbolic link for the path with "md-content" prefix
echo -e "${YELLOW}Creating symbolic link for path with md-content prefix...${NC}"
mkdir -p "${DIST_DIR}/md-content262c9362fd2f6e2f"
ln -sf "${CONTENT_DIR}/${SPECIFIC_FILE}" "${DIST_DIR}/md-content${SPECIFIC_FILE}.json"

echo -e "${GREEN}Created symbolic link at: ${DIST_DIR}/md-content${SPECIFIC_FILE}.json${NC}"

# 3. Check content mapping file for references to this file
echo -e "${YELLOW}Checking content mapping file...${NC}"
MAPPING_FILE="${DIST_DIR}/nform-content-mapping.json"

if [ -f "$MAPPING_FILE" ]; then
    if grep -q "${SPECIFIC_FILE}" "$MAPPING_FILE"; then
        echo -e "${GREEN}File is referenced in mapping file${NC}"
    else
        echo -e "${RED}File not found in mapping file${NC}"
        
        # Update the mapping file to include this file
        echo -e "${YELLOW}Updating mapping file...${NC}"
        TEMP_FILE=$(mktemp)
        jq ". += {\"md-content${SPECIFIC_FILE}\": \"md-content/${SPECIFIC_FILE}\"}" "$MAPPING_FILE" > "$TEMP_FILE"
        mv "$TEMP_FILE" "$MAPPING_FILE"
        
        echo -e "${GREEN}Updated mapping file${NC}"
    fi
else
    echo -e "${RED}Mapping file not found: ${MAPPING_FILE}${NC}"
    
    # Create a basic mapping file
    echo -e "${YELLOW}Creating basic mapping file...${NC}"
    cat > "$MAPPING_FILE" << EOL
{
  "md-content${SPECIFIC_FILE}": "md-content/${SPECIFIC_FILE}"
}
EOL
    
    echo -e "${GREEN}Created mapping file: ${MAPPING_FILE}${NC}"
fi

# 4. Restart the content server
echo -e "${YELLOW}Restarting content server...${NC}"
CONTENT_SERVER_PID=$(lsof -i:4202 -t || echo "")

if [ -n "$CONTENT_SERVER_PID" ]; then
    echo "Stopping existing content server (PID: $CONTENT_SERVER_PID)"
    kill -9 $CONTENT_SERVER_PID 2>/dev/null
fi

echo "Starting content server..."
node content-server.js > content-server.log 2>&1 &
CONTENT_SERVER_PID=$!
echo "Content server started with PID: $CONTENT_SERVER_PID"

echo -e "${GREEN}=== Fix Complete ===${NC}"
echo "Try accessing: http://localhost:4201/md-content262c9362fd2f6e2f.json"
echo "You can also check directly: http://localhost:4202/md-content262c9362fd2f6e2f.json"
