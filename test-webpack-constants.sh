#!/bin/zsh
# Test if the webpack constants are properly defined

echo "Testing webpack constants integration..."

# Run the fix script first
./fix-webpack-constants.sh

# Create a test file
cat > test-constants.js << EOL
// Test if webpack constants are properly defined
const fs = require('fs');
const path = require('path');

// Check if webpack constants JSON exists
const constantsPath = path.resolve(__dirname, 'dist/webpack-constants.json');
if (fs.existsSync(constantsPath)) {
  const constants = require(constantsPath);
  console.log('Webpack constants from JSON file:');
  console.log(JSON.stringify(constants, null, 2));
} else {
  console.log('Webpack constants JSON file not found at:', constantsPath);
}

// Log our message
console.log('\nTest complete. If you see the constants above, the fallback JSON file is working.');
console.log('When building, the WebpackConstantsPlugin will define these constants globally.');
EOL

# Run the test
node test-constants.js

echo "Test complete. To fully confirm the fix, run './build-with-constants.sh' to build the app with constants."
