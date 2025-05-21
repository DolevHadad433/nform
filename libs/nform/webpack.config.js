/**
 * Custom webpack configuration for ng-packagr
 * 
 * This file can be referenced in project.json to customize the webpack build
 * for libraries using the Nx workspace.
 */

console.log('Initializing Webpack configuration...');

module.exports = (config, context) => {
  // Your webpack customizations go here
  console.log('Webpack config customized for library build');
  
  return config;
};
