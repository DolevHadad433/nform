/**
 * Custom webpack configuration for content structure
 */
const path = require('path');
const FixContentStructurePlugin = require('../../../tools/fix-content-structure-plugin');

module.exports = (config, options) => {
  console.log('Applying content structure fix to webpack config...');
  
  // Add our plugin to the webpack config
  if (!config.plugins) {
    config.plugins = [];
  }
  
  // Add the content structure fix plugin
  config.plugins.push(new FixContentStructurePlugin({
    pagesJsonPath: 'md-content/pages.json',
    generateContentFiles: true
  }));
  
  console.log('Content structure fix plugin added to webpack config');
  
  return config;
};
