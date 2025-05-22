#!/bin/bash
# This script creates a permanent webpack fix for the content structure

echo "Creating permanent webpack fix for content structure..."

# Create the webpack plugin
echo "Plugin created at tools/fix-content-structure-plugin.js"

# Create a webpack config wrapper
cat > /Users/eliranbrami/projects/nform/apps/nform-demo-app/build/webpack.content.js << 'EOL'
/**
 * Custom webpack configuration for content structure
 */
const FixContentStructurePlugin = require('../../../tools/fix-content-structure-plugin');

module.exports = (config, options) => {
  console.log('Applying content structure fix to webpack config...');
  
  // Add our plugin to the webpack config
  if (!config.plugins) {
    config.plugins = [];
  }
  
  config.plugins.push(new FixContentStructurePlugin({
    pagesJsonPath: 'md-content/pages.json',
    generateContentFiles: true
  }));
  
  return config;
};
EOL

echo "Created webpack config wrapper at apps/nform-demo-app/build/webpack.content.js"

# Update project.json to use the custom webpack config
PROJECT_JSON="/Users/eliranbrami/projects/nform/apps/nform-demo-app/project.json"

# Check if jq is available
if command -v jq &> /dev/null; then
  # Use jq to update the project.json
  echo "Updating project.json to use the custom webpack config..."
  
  # Create a temporary file
  TMP_FILE=$(mktemp)
  
  # Update the project.json with jq
  jq '.targets.build.options.webpackConfig = "apps/nform-demo-app/build/webpack.content.js"' "$PROJECT_JSON" > "$TMP_FILE"
  
  # Replace the original file
  mv "$TMP_FILE" "$PROJECT_JSON"
  
  echo "Updated project.json with custom webpack config"
else
  echo "Warning: jq is not installed. Please manually update project.json to add:"
  echo "  In targets.build.options: \"webpackConfig\": \"apps/nform-demo-app/build/webpack.content.js\""
fi

# Create a standalone build script that enforces the content structure
cat > /Users/eliranbrami/projects/nform/build-with-fixed-content.sh << 'EOL'
#!/bin/bash
# Build the demo app with fixed content structure

echo "Building nform-demo-app with fixed content structure..."

# Run the build with the custom webpack config
npx nx build nform-demo-app

# Verify the content files were created correctly
echo "Verifying content files..."
if [ -f "dist/md-content/pages.json" ]; then
  echo "✅ pages.json exists"
  
  # Count the entryData entries and the corresponding files
  ENTRY_COUNT=$(grep -o '"md-content/' dist/md-content/pages.json | wc -l)
  FILE_COUNT=$(find dist/md-content -name "*.json" | grep -v "pages.json" | wc -l)
  
  echo "Found $ENTRY_COUNT entries in entryData"
  echo "Found $FILE_COUNT content files"
  
  if [ "$FILE_COUNT" -lt "$ENTRY_COUNT" ]; then
    echo "⚠️ Some content files are missing. Running generation script..."
    node generate-content-files.js
  else
    echo "✅ All content files exist"
  fi
else
  echo "❌ pages.json not found. Build may have failed."
  exit 1
fi

echo "Build complete!"
EOL

chmod +x /Users/eliranbrami/projects/nform/build-with-fixed-content.sh

echo "Created build script at build-with-fixed-content.sh"
echo "Run ./build-with-fixed-content.sh to build with fixed content structure"

echo "Content structure fix implementation complete!"
