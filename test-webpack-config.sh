#!/bin/zsh
# Test script to verify that webpack.config.ts is being loaded and executed
# This script helps verify that the console.log statements in webpack.config.ts
# are displayed correctly when the file is imported and executed

cd "$(dirname "$0")"

echo "Testing webpack.config.ts execution using our custom loader..."
node -r ./tools/webpack-config-loader.js -e "require('./tools/webpack-config-loader')()"
echo "Test complete"
