#!/bin/zsh
# Restart the NFORM development server with proper content

# Kill any existing Angular development server
echo "Stopping existing development servers..."
pkill -f "ng serve" || echo "No running Angular server found"

# Setup the development environment
echo "Setting up development environment..."
./setup-dev-environment.sh

# Create necessary directories
mkdir -p dist/browser/md-content
mkdir -p apps/nform-demo-app/src/assets/md-content

# Copy content files
echo "Copying content files..."
cp dist/nform-content-mapping.json dist/browser/
cp dist/md-content/*.json dist/browser/md-content/

cp dist/nform-content-mapping.json apps/nform-demo-app/src/assets/
cp dist/md-content/*.json apps/nform-demo-app/src/assets/md-content/

# Start the development server
echo "Starting development server..."
yarn start
