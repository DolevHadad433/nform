#!/bin/zsh
# Script to build the application with webpack constants correctly defined

echo "Starting build with proper webpack constants..."

# Run the fix first to ensure the webpack constants plugin is set up
./fix-webpack-constants.sh

# Now run the build
echo "Running npm build with constants fix applied..."
npm run build-lib

echo "Build completed with webpack constants integration"
