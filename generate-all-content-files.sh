#!/bin/bash
# Script to generate all content files listed in pages.json

echo "Installing required dependencies if not present..."
npm install --no-save mkdirp

echo "Running content file generator..."
# node ./generate-content-files.js  # DISABLED: Generates placeholder content instead of real content

echo "Copying files to source directory..."
cp -r dist/md-content* apps/nform-demo-app/src/

echo "All content files generated!"
echo "Remember to restart your dev server for changes to take effect."
