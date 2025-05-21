#!/bin/zsh
# Script to run a build with the NFORM_CONTENT_MAPPING_FILE environment variable set

# Set the environment variable
export NFORM_CONTENT_MAPPING_FILE="nform-content-mapping.json"

# Run the build
echo "Running build with NFORM_CONTENT_MAPPING_FILE=${NFORM_CONTENT_MAPPING_FILE}..."
yarn build-lib

# Generate the nform-content-mapping.json file
echo "Generating content mapping file..."
node tools/generate-content-mapping.js

echo "Build completed with content mapping file generated"
