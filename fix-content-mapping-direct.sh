#!/bin/zsh
# Direct webpack fix for content mapping files
# This script copies the required files directly to the server's output directory

echo "Applying direct webpack fix for content mapping files..."

# 1. First check if server is running
if ! nc -z localhost 4201 > /dev/null 2>&1; then
  echo "Error: Development server doesn't appear to be running on port 4201."
  echo "Please start the server first with 'nx serve nform-demo-app' and try again."
  exit 1
fi

# 2. Get webpack output directory (typically stored in memory via webpack-dev-server)
# For Angular CLI, this is usually served from memory but may be temporarily written to disk
WEBPACK_OUTPUT_DIR="$(pwd)/.nx/cache/dev-server/nform-demo-app"

# Create directory if it doesn't exist (for backup approach)
mkdir -p "$WEBPACK_OUTPUT_DIR"

# 3. Copy files directly to both possible serving locations
echo "Copying content mapping files to webpack output directory..."

# Primary approach - copy to root
cp dist/nform-content-mapping.json "$WEBPACK_OUTPUT_DIR/"
mkdir -p "$WEBPACK_OUTPUT_DIR/md-content"
cp dist/md-content/*.json "$WEBPACK_OUTPUT_DIR/md-content/"

# Fallback approach - copy to assets directory
mkdir -p "$WEBPACK_OUTPUT_DIR/assets/md-content"
cp dist/nform-content-mapping.json "$WEBPACK_OUTPUT_DIR/assets/"
cp dist/md-content/*.json "$WEBPACK_OUTPUT_DIR/assets/md-content/"

echo "Content mapping files copied to webpack output directory"
echo "Testing file access..."

# 4. Test the file access to verify it worked
if curl -s -f -I http://localhost:4201/nform-content-mapping.json > /dev/null; then
  echo "✅ nform-content-mapping.json is accessible"
else
  echo "❌ nform-content-mapping.json is NOT accessible"
  echo "Trying alternative location..."
  
  if curl -s -f -I http://localhost:4201/assets/nform-content-mapping.json > /dev/null; then
    echo "✅ /assets/nform-content-mapping.json is accessible"
  else
    echo "❌ /assets/nform-content-mapping.json is NOT accessible"
  fi
fi

# Test md-content access
if curl -s -f -I http://localhost:4201/md-content/pages.json > /dev/null; then
  echo "✅ md-content/pages.json is accessible"
else
  echo "❌ md-content/pages.json is NOT accessible"
  
  if curl -s -f -I http://localhost:4201/assets/md-content/pages.json > /dev/null; then
    echo "✅ /assets/md-content/pages.json is accessible"
  else
    echo "❌ /assets/md-content/pages.json is NOT accessible"
  fi
fi

echo "Direct fix applied - if files are still inaccessible, please rebuild your app with 'nx build nform-demo-app'"
