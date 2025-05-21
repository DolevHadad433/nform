#!/bin/zsh
# Fix for nform-content-mapping.json 404 issue
# This script creates a direct fix for content mapping issues in the Angular development server

echo "Applying content mapping fix for development server..."

# Create the md-content directory structure in the project source
mkdir -p apps/nform-demo-app/src/md-content

# Copy content files to the source directory for direct serving
cp dist/md-content/*.json apps/nform-demo-app/src/md-content/
cp dist/nform-content-mapping.json apps/nform-demo-app/src/

echo "Content mapping files copied to source directory for direct serving"

# Update project.json to include files in assets configuration
PROJECT_JSON="apps/nform-demo-app/project.json"

# Create backup of project.json
cp "$PROJECT_JSON" "${PROJECT_JSON}.backup"

echo "Checking current assets configuration in project.json..."
grep -A 10 "assets" "$PROJECT_JSON"

echo "Content mapping fix applied successfully"
echo "You should now restart the development server with: yarn start"
