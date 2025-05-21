#!/bin/zsh
# This script fixes the format of pages.json to include entries and entryData objects
# which are required by the MarkdownPagesService and MarkdownPagesMenuService

echo "Fixing entries format in pages.json..."

# Run the updated content generator script
node ./tools/generate-content-mapping.js

# Apply comprehensive fix
./fix-content-mapping-comprehensive.sh

echo "Format fix completed. Remember to restart your dev server for changes to take effect."
echo "If you're still seeing issues, run: ./restart-dev-server-with-content.sh"
