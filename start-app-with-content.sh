#!/bin/zsh
# Wrapper script to start the simplified content solution and run the app

echo "Starting nForm demo app with simplified content solution..."

# 1. Run the simplified content solution
./simplified-content-solution.sh

# 2. Wait a moment for the content server to start
sleep 2

# 3. Check if the content server is running
if curl -s http://localhost:4202/nform-content-mapping.json > /dev/null; then
  echo "✅ Content server is running successfully"
else
  echo "❌ Content server is not running. Check content-server.log for details."
  exit 1
fi

# 4. Start the Angular app
echo "Starting Angular app..."
npm run start
