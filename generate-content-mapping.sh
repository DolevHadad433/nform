#!/bin/zsh
# Generate nform-content-mapping.json

# Set the output file path
MAPPING_FILE="nform-content-mapping.json"
DIST_DIR="/Users/eliranbrami/projects/nform/dist"

echo "Generating ${MAPPING_FILE}..."

# Create an empty mapping file in the dist directory
cat > ${DIST_DIR}/${MAPPING_FILE} << 'EOL'
{
  "markdownPages": "md-content/pages.json",
  "markdownCodeExamples": "md-content/code-examples.json",
  "searchContent": "md-content/search-content.json"
}
EOL

echo "Created ${MAPPING_FILE} in ${DIST_DIR}"
echo "This file contains the mappings needed by content-map.service.ts"
