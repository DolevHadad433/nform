#!/bin/zsh
# Script to update a specific content file with rich HTML content

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check parameters
if [ $# -lt 2 ]; then
  echo -e "${RED}Error: Missing parameters${NC}"
  echo -e "Usage: $0 <content-id> \"<rich-html-content>\""
  echo -e "Example: $0 quick-start \"<div pbl-app-content-chunk=\\\"pbl-quick-start-app-content-chunk\\\"></div>\n<h1>Quick Start Guide</h1>\""
  exit 1
fi

CONTENT_ID=$1
RICH_CONTENT=$2

echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}      nForm Content Update Tool               ${NC}"
echo -e "${BLUE}===============================================${NC}"

# Ensure dist directory exists
if [ ! -d "dist" ]; then
  echo -e "${YELLOW}Creating dist directory...${NC}"
  mkdir -p "dist"
fi

# Ensure md-content directory exists
if [ ! -d "dist/md-content" ]; then
  echo -e "${YELLOW}Creating md-content directory...${NC}"
  mkdir -p "dist/md-content"
fi

# Create or update the content file
echo -e "${YELLOW}Creating/updating content file for ${CONTENT_ID}...${NC}"

CONTENT_FILE="dist/md-content/${CONTENT_ID}.json"
cat > "$CONTENT_FILE" << EOL
{
  "id": "${CONTENT_ID}",
  "title": "$(echo ${CONTENT_ID} | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')",
  "contents": "${RICH_CONTENT}"
}
EOL

echo -e "${GREEN}Updated content file: ${CONTENT_FILE}${NC}"

# Create direct access file (without ID)
DIRECT_FILE="dist/md-content${CONTENT_ID}.json"
cp "$CONTENT_FILE" "$DIRECT_FILE"
echo -e "${GREEN}Created direct access file: ${DIRECT_FILE}${NC}"

# Update source content file if it exists
SOURCE_DIR="apps/nform-demo-app/src/md-content"
if [ -d "$SOURCE_DIR" ]; then
  SOURCE_FILE="${SOURCE_DIR}/${CONTENT_ID}.json"
  cp "$CONTENT_FILE" "$SOURCE_FILE"
  echo -e "${GREEN}Updated source content file: ${SOURCE_FILE}${NC}"
else
  echo -e "${YELLOW}Source directory not found: ${SOURCE_DIR}${NC}"
fi

# Check for special directory for this content
SPECIAL_DIR="apps/nform-demo-app/src/md-content${CONTENT_ID}"
if [ -d "$SPECIAL_DIR" ]; then
  echo -e "${YELLOW}Checking special directory: ${SPECIAL_DIR}${NC}"
  
  # Find all JSON files in the special directory
  for FILE in ${SPECIAL_DIR}/*.json; do
    if [ -f "$FILE" ]; then
      BASENAME=$(basename "$FILE")
      cp "$CONTENT_FILE" "$FILE"
      echo -e "${GREEN}Updated special content file: ${FILE}${NC}"
      
      # Create corresponding direct file
      SPECIAL_DIRECT_FILE="dist/md-content${CONTENT_ID}${BASENAME}"
      cp "$CONTENT_FILE" "$SPECIAL_DIRECT_FILE"
      echo -e "${GREEN}Created special direct file: ${SPECIAL_DIRECT_FILE}${NC}"
    fi
  done
fi

# Update mapping file
MAPPING_FILE="dist/nform-content-mapping.json"
if [ ! -f "$MAPPING_FILE" ]; then
  echo -e "${YELLOW}Creating mapping file...${NC}"
  echo "{}" > "$MAPPING_FILE"
fi

# Update mapping using temporary file and jq if available
if command -v jq &> /dev/null; then
  TEMP_FILE=$(mktemp)
  jq --arg key "md-content${CONTENT_ID}" --arg value "md-content/${CONTENT_ID}.json" \
     '. + {($key): $value}' "$MAPPING_FILE" > "$TEMP_FILE"
  mv "$TEMP_FILE" "$MAPPING_FILE"
  echo -e "${GREEN}Updated mapping file for ${CONTENT_ID}${NC}"
else
  echo -e "${YELLOW}Warning: jq not found, skipping mapping update${NC}"
  echo -e "${YELLOW}Consider installing jq for better mapping file handling${NC}"
fi

echo -e "${GREEN}Content update completed for ${CONTENT_ID}${NC}"
echo -e "To verify the content is accessible, run:"
echo -e "${YELLOW}curl -s http://localhost:4202/md-content${CONTENT_ID}.json | jq${NC}"
