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
