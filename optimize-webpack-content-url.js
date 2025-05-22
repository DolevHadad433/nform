/**
 * Script to optimize webpack configuration to properly expose the content server URL
 */
const fs = require('fs');
const path = require('path');

// Paths
const webpackConfigPath = path.join(__dirname, 'apps', 'nform-demo-app', 'build', 'webpack.config.ts');

// Read the webpack config file
console.log('Reading webpack config file...');
const webpackConfig = fs.readFileSync(webpackConfigPath, 'utf8');

// Check if CONTENT_SERVER_URL is already in the DefinePlugin
if (webpackConfig.includes('CONTENT_SERVER_URL: JSON.stringify(CONTENT_SERVER_URL)')) {
  console.log('CONTENT_SERVER_URL is already properly configured in DefinePlugin');
  process.exit(0);
}

// Find the DefinePlugin definitions area
const definePluginRegex = /return\s*{([^}]*)}/;
const match = webpackConfig.match(definePluginRegex);

if (!match) {
  console.error('Could not find DefinePlugin definitions area in webpack config');
  process.exit(1);
}

// Add CONTENT_SERVER_URL to the DefinePlugin definitions
const currentDefinitions = match[1];
const newDefinitions = currentDefinitions + ',\n      CONTENT_SERVER_URL: JSON.stringify(CONTENT_SERVER_URL)';

// Replace the definitions
const updatedWebpackConfig = webpackConfig.replace(definePluginRegex, `return {${newDefinitions}}`);

// Write back the updated webpack config
console.log('Writing updated webpack config...');
fs.writeFileSync(webpackConfigPath, updatedWebpackConfig, 'utf8');

console.log('Webpack config updated successfully!');
console.log('CONTENT_SERVER_URL is now properly exposed to the application');
