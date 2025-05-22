#!/bin/bash
# Build the demo app with fixed content structure

echo "===== Building nform-demo-app with fixed content structure ====="

# Update project.json with the custom webpack config
echo "Updating project.json to use custom webpack config..."
node update-project-webpack-config.js

# Run the build with the custom webpack config
echo "Running build with content structure fixes..."
npx nx build nform-demo-app

# Verify the content files were created correctly
echo "Verifying content files..."
if [ -f "dist/md-content/pages.json" ]; then
  echo "✅ pages.json exists"
  
  # Run the improved content files generator to ensure all files exist
  echo "Running content files generator to ensure all files exist..."
  node generate-content-files-improved.js
  
  # Fix the quick-start content specifically
  echo "Fixing quick-start content..."
  ./fix-quick-start-content.sh
  
  # Count the entryData entries and the corresponding files
  ENTRY_COUNT=$(grep -o '"md-content/' dist/md-content/pages.json | wc -l)
  FILE_COUNT=$(find dist/md-content -name "*.json" | grep -v "pages.json" | wc -l)
  
  echo "Found $ENTRY_COUNT entries in entryData"
  echo "Found $FILE_COUNT content files"
  
  if [ "$FILE_COUNT" -lt "$ENTRY_COUNT" ]; then
    echo "⚠️ Some content files are missing. Running generation script again..."
    node generate-content-files-improved.js
  else
    echo "✅ All content files exist"
  fi
  
  # Update the content server to use the correct port
  echo "Updating content server configuration..."
  sed -i '' 's/port = 4201/port = 4202/g' content-server.js 2>/dev/null || sed -i 's/port = 4201/port = 4202/g' content-server.js
  
  # Start the content server
  echo "Starting content server on port 4202..."
  nohup node content-server.js > content-server.log 2>&1 &
  echo "Content server started in background. Check content-server.log for details."
  echo "Content server available at: http://localhost:4202"
else
  echo "❌ pages.json not found. Build may have failed."
  exit 1
fi

echo "===== Content structure fix implementation complete! ====="
echo "You can now serve the app with: npm run start"
echo "The content will be served from the content server at http://localhost:4202"
echo "Make sure ContentMapService is configured to use port 4202"
