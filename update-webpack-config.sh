#!/bin/zsh

# Go to project root folder
cd /Users/eliranbrami/projects/nform

echo "Creating backup of webpack configurations..."
timestamp=$(date +%Y%m%d%H%M%S)
mkdir -p webpack-backup-$timestamp

# Find all webpack configuration files and create backups
find . -name "webpack.config*.js" -not -path "*/node_modules/*" -not -path "*/dist/*" | xargs -I {} cp {} webpack-backup-$timestamp/

# Update webpack configuration files for Angular 16 compatibility
echo "Updating webpack configurations for Angular 16..."

# Find all webpack config files
webpack_configs=$(find . -name "webpack.config*.js" -not -path "*/node_modules/*" -not -path "*/dist/*")

for config_file in $webpack_configs; do
  echo "Updating $config_file..."
  
  # Replace deprecated webpack options
  sed -i '' 's/mode: "none"/mode: "development"/g' $config_file
  
  # Update CommonJS dependencies warning suppression for webpack 5
  sed -i '' 's/allowedCommonJsDependencies/allowedCommonJsDependencies/g' $config_file
  
  # Update module.rules syntax if needed
  sed -i '' 's/new AngularCompilerPlugin(/new AngularWebpackPlugin(/g' $config_file
  
  # Replace @ngtools/webpack references
  sed -i '' 's/require("@ngtools\/webpack")/require("@angular-devkit\/build-angular\/src\/webpack\/plugins\/angular-webpack-plugin")/g' $config_file
  sed -i '' 's/const { AngularCompilerPlugin } = require("@ngtools\/webpack")/const { AngularWebpackPlugin } = require("@angular-devkit\/build-angular\/src\/webpack\/plugins\/angular-webpack-plugin")/g' $config_file
  
  # Add additional fixes as needed
done

echo "Webpack configuration updates completed. Please review the changes manually to ensure everything is correct."
