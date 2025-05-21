#!/bin/zsh
# Update webpack configuration to include content mapping files plugin
# This script modifies the webpack configuration to ensure content files are available

echo "Updating webpack configuration for content mapping files..."

# Path to webpack configuration files
WEBPACK_CONFIG_PATH="apps/nform-demo-app/build/webpack.config.ts"
BACKUP_PATH="${WEBPACK_CONFIG_PATH}.backup-content-mapping"

# Create backup if it doesn't exist
if [ ! -f "$BACKUP_PATH" ]; then
  cp "$WEBPACK_CONFIG_PATH" "$BACKUP_PATH"
  echo "Created backup of webpack config at $BACKUP_PATH"
fi

# Check if ContentMappingFilesPlugin is already added
if grep -q "ContentMappingFilesPlugin" "$WEBPACK_CONFIG_PATH"; then
  echo "ContentMappingFilesPlugin already added to webpack config"
else
  # Add the require statement for the plugin at the top of the file
  echo "Adding ContentMappingFilesPlugin to webpack config..."
  
  # Use sed to add the require statement after other requires
  sed -i '' '/const remarkAttr = require/a \
  const ContentMappingFilesPlugin = require("../../tools/content-mapping-files-plugin");
  ' "$WEBPACK_CONFIG_PATH"
  
  # Add the plugin instantiation with the other plugins
  sed -i '' '/webpackConfig.plugins.push(new PebulaDynamicDictionaryWebpackPlugin/a \
  webpackConfig.plugins.push(new ContentMappingFilesPlugin());
  ' "$WEBPACK_CONFIG_PATH"
  
  echo "ContentMappingFilesPlugin added to webpack config"
fi

# Create a script to start the server with the updated webpack config
cat > "serve-with-content-mapping.sh" << 'EOL'
#!/bin/zsh
# Serve the application with content mapping files available

# Ensure content mapping files exist
node ./tools/generate-content-mapping.js

# Copy files to source directories as a backup approach
mkdir -p apps/nform-demo-app/src/md-content
cp dist/nform-content-mapping.json apps/nform-demo-app/src/
cp dist/md-content/*.json apps/nform-demo-app/src/md-content/

# Start the server
nx serve nform-demo-app
EOL

chmod +x serve-with-content-mapping.sh

echo "Created serve-with-content-mapping.sh script"
echo "To start the server with content mapping files available, run: ./serve-with-content-mapping.sh"
