#!/usr/bin/env node

// This script loads and executes the webpack.config.ts file directly
// to ensure the console log statements are displayed

const path = require('path');
const tsConfigPath = path.resolve(__dirname, 'apps/nform-demo-app/build/tsconfig.json');
const webpackConfigPath = path.resolve(__dirname, 'apps/nform-demo-app/build/webpack.config.ts');

// Register ts-node to handle TypeScript files
try {
  require('ts-node').register({ 
    project: tsConfigPath,
    transpileOnly: true 
  });

  // Now require and execute the webpack config
  const updateWebpackConfig = require(webpackConfigPath);
  
  // Create a mock webpack config that has the minimum structure needed
  const mockConfig = {
    resolveLoader: { modules: [] },
    module: { rules: [] },
    plugins: []
  };
  
  // Execute the function to trigger the console.log statements
  updateWebpackConfig(mockConfig);
  
  console.log('Successfully executed webpack.config.ts');
} catch (error) {
  console.error('Error executing webpack.config.ts:', error.message);
  console.error(error.stack);
}
