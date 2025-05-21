// Test webpack config to define NFORM_CONTENT_MAPPING_FILE
const path = require('path');
const webpack = require('webpack');

// Import the AsyncDefinePlugin from the webpack.config.ts file
const AsyncDefinePlugin = require('./apps/nform-demo-app/build/webpack.config.ts').AsyncDefinePlugin;

// Create a simple webpack configuration
const config = {
  mode: 'development',
  entry: './test-define.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'test-bundle.js'
  },
  plugins: [
    // Define NFORM_CONTENT_MAPPING_FILE directly
    new webpack.DefinePlugin({
      'NFORM_CONTENT_MAPPING_FILE': JSON.stringify('nform-content-mapping.json')
    })
  ]
};

console.log('Test webpack configuration created');
console.log('NFORM_CONTENT_MAPPING_FILE should be defined as "nform-content-mapping.json"');

module.exports = config;
