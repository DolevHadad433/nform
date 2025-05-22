#!/bin/zsh
# Fix for Webpack ENOTDIR errors with package.json files
# Date: May 22, 2025

# This script fixes the ENOTDIR watchpack error that occurs when webpack 
# incorrectly tries to scan package.json files as if they were directories.
# The error typically looks like:
# Watchpack Error (initial scan): Error: ENOTDIR: not a directory, scandir '/path/to/package.json'

# The problem is caused by incorrectly requiring package.json files in webpack configurations
# using Path.join instead of require.resolve.

echo "Fixing webpack configuration to properly require package.json files"

# Function to check and fix webpack configs
fix_webpack_config() {
    local file_path=$1
    
    if [ -f "$file_path" ]; then
        echo "Checking $file_path for incorrect package.json requires"
        
        # Check if the file contains the incorrect require pattern
        if grep -q "require(Path.join.*package.json" "$file_path"; then
            echo "Found incorrect package.json require pattern in $file_path, fixing..."
            
            # Create a backup
            cp "$file_path" "${file_path}.backup-$(date +%Y%m%d%H%M%S)"
            
            # Replace the incorrect pattern with require.resolve
            sed -i'.bak' 's|require(Path.join(process.cwd(), `\(.*\)/package.json`))|require(require.resolve("../../\1/package.json"))|g' "$file_path"
            
            echo "Fixed $file_path"
        else
            echo "No issues found in $file_path"
        fi
    else
        echo "File $file_path does not exist, skipping"
    fi
}

# Fix webpack configs in various locations
fix_webpack_config "apps/nform-demo-app/build/webpack.config.ts"
fix_webpack_config "apps/nform-demo-app/build/custom-webpack.config.js"

echo "Fix completed. Please restart your development server."

# Explanation of the fix:
# ---------------------
# The issue occurs when webpack tries to watch package.json files as if they were directories.
# This happens because of using Path.join to resolve file paths for package.json files.
#
# Instead of:
#   const nform = require(Path.join(process.cwd(), `libs/nform/package.json`));
#
# We use:
#   const nformPackagePath = require.resolve('../../libs/nform/package.json');
#   const nform = require(nformPackagePath);
#
# This ensures that webpack correctly treats the package.json as a file and not a directory.
