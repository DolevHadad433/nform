#!/bin/bash
# Complete solution for building nform-demo-app with fixed content structure

echo "===== Building nform-demo-app with fixed content structure ====="

# 1. Ensure our webpack plugin exists
if [ ! -f "tools/fix-content-structure-plugin.js" ]; then
  echo "Error: Webpack plugin not found. Please run fix-webpack-for-content.sh first."
  exit 1
fi

# 2. Update the project to use the custom builder
echo "Configuring project to use custom webpack builder..."
./update-project-for-custom-builder.sh

# 3. Run the build
echo "Running build with custom webpack builder..."
npx nx build nform-demo-app

# 4. Verify the built files
echo "Verifying content files..."
if [ -f "dist/browser/md-content/pages.json" ]; then
  echo "✅ pages.json exists"
  
  # Run the improved content files generator to ensure all files exist
  echo "Running content files generator to ensure all files exist..."
  node generate-content-files-improved.js
  
  # Start the content server
  echo "Starting content server on port 4202..."
  nohup node content-server.js > content-server.log 2>&1 &
  echo "Content server started in background. Check content-server.log for details."
  echo "Content server available at: http://localhost:4202"
  
  echo "✅ Build completed successfully!"
else
  echo "❌ pages.json not found. Build may have failed."
  exit 1
fi

echo "===== Content structure fix implementation complete! ====="
echo "You can now serve the app with: npm run start"
echo "The content will be served from the content server at http://localhost:4202"
