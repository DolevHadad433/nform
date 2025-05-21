#!/bin/zsh
# Setup development environment for NFORM
# This script ensures the content mapping file and associated content files are available for development

echo "Setting up NFORM development environment..."

# Generate the content mapping file if it doesn't exist
if [ ! -f "dist/nform-content-mapping.json" ]; then
  echo "Generating content mapping file..."
  node ./tools/generate-content-mapping.js
fi

# Create empty JSON files for md-content if they don't exist
mkdir -p dist/md-content
if [ ! -f "dist/md-content/pages.json" ]; then
  echo '{"pages":[]}' > dist/md-content/pages.json
fi
if [ ! -f "dist/md-content/code-examples.json" ]; then
  echo '{"examples":[]}' > dist/md-content/code-examples.json
fi
if [ ! -f "dist/md-content/search-content.json" ]; then
  echo '{"content":[]}' > dist/md-content/search-content.json
fi

# Ensure the assets directory exists
mkdir -p apps/nform-demo-app/src/assets/md-content

# Copy content files to the assets directory
cp dist/nform-content-mapping.json apps/nform-demo-app/src/assets/
cp dist/md-content/*.json apps/nform-demo-app/src/assets/md-content/
echo "Copied content files to assets directory"

# Copy to browser dist if it exists (for non-dev-server builds)
if [ -d "dist/browser" ]; then
  mkdir -p dist/browser/md-content
  cp dist/nform-content-mapping.json dist/browser/
  cp dist/md-content/*.json dist/browser/md-content/
  echo "Copied content files to dist/browser/"
fi

echo "Development environment is ready!"
