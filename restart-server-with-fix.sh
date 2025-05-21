#!/bin/zsh
# Restart development server after applying content mapping fix

echo "Restarting development server with content mapping fix..."

# Kill any existing development servers
pkill -f "ng serve" || echo "No Angular server to kill"

# Apply the content mapping fix
./fix-content-mapping-final.sh

# Start the server in the background
nx serve nform-demo-app &

# Wait a bit for the server to start
echo "Waiting for server to start..."
sleep 10

# Test the content mapping file
echo "Testing content mapping file access..."
curl -I http://localhost:4201/nform-content-mapping.json

echo "Development server restarted! Access the app at http://localhost:4201"
