#!/bin/zsh
# Script to run a clean build of the library, ensuring webpack.config.ts is executed

# Clear the Nx cache
echo "Clearing Nx cache..."
yarn nx reset

# Set the environment variable
export NFORM_CONTENT_MAPPING_FILE="nform-content-mapping.json"

# Run the build without using the cache
echo "Running clean build with NFORM_CONTENT_MAPPING_FILE=${NFORM_CONTENT_MAPPING_FILE}..."
yarn build-lib --skip-nx-cache

# Generate the nform-content-mapping.json file
echo "Generating content mapping file..."
node tools/generate-content-mapping.js

echo "Build completed with environment variable set and content mapping file generated"
