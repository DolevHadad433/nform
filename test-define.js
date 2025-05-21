// Check if webpack properly defines the constant during build
const webpack = require('webpack');

const definePlugin = new webpack.DefinePlugin({
  'NFORM_CONTENT_MAPPING_FILE': JSON.stringify('nform-content-mapping.json')
});

console.log('DefinePlugin created with NFORM_CONTENT_MAPPING_FILE definition');
console.log('This should make the constant available to the TypeScript code during compilation');
