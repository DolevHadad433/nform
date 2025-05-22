#!/bin/bash
# Script to serve the application with content mapping and direct file access

echo "Setting up content files..."
./generate-all-content-files.sh
./fix-content-symlinks.sh

echo "Starting dev server with custom file serving..."
cd apps/nform-demo-app && node ../../node_modules/@angular/cli/bin/ng.js serve --port 4201 --serve-path=/ --live-reload=true
