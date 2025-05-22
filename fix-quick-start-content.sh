#!/bin/zsh
# Script to fix the quick-start content file properly

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Fixing Quick Start Content ===${NC}"

# Define paths
DIST_DIR="$(pwd)/dist"
CONTENT_DIR="${DIST_DIR}/md-content"
QUICK_START_DIR="${DIST_DIR}/md-contentquick-start"
SOURCE_FILE="${CONTENT_DIR}/quick-start.json"
TARGET_FILE="${QUICK_START_DIR}/262c9362fd2f6e2f.json"

# Ensure the source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo -e "${RED}Source file does not exist: ${SOURCE_FILE}${NC}"
    echo -e "${YELLOW}Creating source file with rich content...${NC}"
    
    # Create directory if it doesn't exist
    mkdir -p "$CONTENT_DIR"
    
    # Create the source file with rich content
    cat > "$SOURCE_FILE" << 'EOL'
{
  "id": "quick-start",
  "title": "Quick Start",
  "contents": "<div pbl-app-content-chunk=\"pbl-quick-start-app-content-chunk\"></div>\n<h1>Quick Start Guide</h1>\n<p>This is the official quick start guide for nForm.</p>\n<br>\n<div pbl-example-view=\"pbl-quick-start-example\" exampleStyle=\"flow\"></div>\n<br>\n<br>"
}
EOL
    echo -e "${GREEN}Created source file: ${SOURCE_FILE}${NC}"
fi

# Ensure target directory exists
mkdir -p "$QUICK_START_DIR"

# Copy content from source to target
echo -e "${YELLOW}Copying content to target file...${NC}"
cp "$SOURCE_FILE" "$TARGET_FILE"
echo -e "${GREEN}Updated target file: ${TARGET_FILE}${NC}"

# Verify the content
if [ -f "$TARGET_FILE" ]; then
    echo -e "${GREEN}Quick Start content file fixed successfully!${NC}"
else
    echo -e "${RED}Failed to create target file: ${TARGET_FILE}${NC}"
    exit 1
fi

echo -e "${GREEN}=== Quick Start Content Fix Completed ===${NC}"
