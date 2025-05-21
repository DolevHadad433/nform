#!/bin/zsh
# Restart development server with content files available

# Kill existing server if running
echo "Stopping existing development servers..."
pkill -f "ng serve" || echo "No running Angular server found"

# Apply content mapping fix
./fix-content-mapping-comprehensive.sh

# Start the server with proper options
echo "Starting development server..."
nx serve nform-demo-app --serve-path="/" --liveReload=true
