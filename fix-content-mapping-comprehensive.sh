#!/bin/zsh
# Comprehensive fix for nform-content-mapping.json and md-content files
# This script creates a complete fix for content access issues in development mode

echo "Applying comprehensive content mapping fix..."

# Step 1: Generate content mapping and md-content files if they don't exist
if [ ! -f "dist/nform-content-mapping.json" ] || [ ! -d "dist/md-content" ]; then
  echo "Generating content mapping files..."
  node ./tools/generate-content-mapping.js
fi

# Step 2: Create directories in the source tree for direct serving
mkdir -p apps/nform-demo-app/src/md-content

# Step 3: Copy all necessary files to the source directory
echo "Copying content files to source directory..."
cp dist/nform-content-mapping.json apps/nform-demo-app/src/
cp -r dist/md-content/*.json apps/nform-demo-app/src/md-content/

# Step 4: Update Angular project.json to serve both local and dist files
# This ensures the files are accessible through multiple paths
PROJECT_JSON="apps/nform-demo-app/project.json"
BACKUP_JSON="${PROJECT_JSON}.content-fix-backup"

# Backup the project.json file
if [ ! -f "$BACKUP_JSON" ]; then
  cp "$PROJECT_JSON" "$BACKUP_JSON"
  echo "Created backup of project.json at $BACKUP_JSON"
fi

# Check if we need to update assets configuration
NEEDS_UPDATE=$(grep -c '"/md-content"' "$PROJECT_JSON" || true)
if [ "$NEEDS_UPDATE" -eq 0 ]; then
  echo "Updating assets configuration in project.json..."
  
  # This is a complex manipulation - we'll use a temp file
  TEMP_FILE=$(mktemp)
  
  # Insert additional assets configuration
  awk '
  /assets": \[/ {
    print $0;
    print "          \"apps/nform-demo-app/src/nform-content-mapping.json\",";
    print "          \"apps/nform-demo-app/src/md-content\",";
    next;
  }
  { print $0 }
  ' "$PROJECT_JSON" > "$TEMP_FILE"
  
  # Replace the original file
  mv "$TEMP_FILE" "$PROJECT_JSON"
else
  echo "Assets configuration already updated."
fi

# Step 5: Create symlink to ensure both paths work
echo "Creating symbolic links for dual-path access..."
if [ -d "dist/browser" ] && [ ! -f "dist/browser/nform-content-mapping.json" ]; then
  cp dist/nform-content-mapping.json dist/browser/
  mkdir -p dist/browser/md-content
  cp dist/md-content/*.json dist/browser/md-content/
fi

echo "Comprehensive content mapping fix applied successfully!"
echo "Please restart your Angular development server for changes to take effect."
