// Custom Webpack Configuration Loader
const path = require('path');
const fs = require('fs');

/**
 * This module loads the webpack.config.ts file from your demo app
 * and ensures it's executed during the build process.
 * 
 * This allows the console.log statements in webpack.config.ts to be displayed
 * during library builds, even though the webpack configuration itself
 * isn't directly used for building the libraries.
 */

function loadWebpackConfig() {
  try {
    console.log('Loading custom webpack configuration from apps/nform-demo-app/build/webpack.config.ts');
    
    // Register ts-node to be able to import TypeScript files
    const tsConfig = path.resolve(__dirname, '../apps/nform-demo-app/build/tsconfig.json');
    process.env.TS_NODE_PROJECT = tsConfig;
    
    try {
      require('tsconfig-paths/register');
      require('ts-node').register({ project: tsConfig });
    } catch (error) {
      console.warn('Error registering ts-node:', error.message);
    }
    
    try {
      // Ensure environment variable is set for NFORM_CONTENT_MAPPING_FILE
      if (!process.env.NFORM_CONTENT_MAPPING_FILE) {
        process.env.NFORM_CONTENT_MAPPING_FILE = 'nform-content-mapping.json';
        console.log('Setting NFORM_CONTENT_MAPPING_FILE environment variable to:', process.env.NFORM_CONTENT_MAPPING_FILE);
      } else {
        console.log('NFORM_CONTENT_MAPPING_FILE already set to:', process.env.NFORM_CONTENT_MAPPING_FILE);
      }
      
      // Import the webpack configuration
      const webpackConfigPath = path.resolve(__dirname, '../apps/nform-demo-app/build/webpack.config.ts');
      const webpackConfig = require(webpackConfigPath);
      console.log('Successfully loaded webpack config from:', webpackConfigPath);
      
      // Execute the configuration function with a mock webpack config
      if (typeof webpackConfig === 'function') {
        console.log('Executing webpack config function');
        
        try {
          // Create a more accurate mock of the Angular webpack plugin
          const AngularWebpackPlugin = require('@ngtools/webpack').AngularWebpackPlugin;
          
          // Create a mock webpack config with a real AngularWebpackPlugin instance
          const mockConfig = {
            resolveLoader: { modules: [] },
            module: { rules: [] },
            plugins: [
              new AngularWebpackPlugin({ 
                directTemplateLoading: true,
                tsconfig: path.resolve(__dirname, '../apps/nform-demo-app/tsconfig.app.json')
              })
            ]
          };
        
          console.log('Created mock webpack config with AngularWebpackPlugin');
          webpackConfig(mockConfig);
        } catch (error) {
          console.log('Error creating mock webpack config:', error.message);
          
          // Fall back to a simple log, without executing the webpack config function
          console.log('NOTE: Only displaying the webpack.config.ts logs without executing the full configuration');
          
          // Create a very simple mock config that doesn't require Angular plugins
          const simpleMockConfig = {
            resolveLoader: { modules: [] },
            module: { rules: [] },
            plugins: []
          };
          
          try {
            // Try with a simplified webpack config that just logs
            console.log('Trying with a simplified webpack config');
            
            // Create a simpler version of the updateWebpackConfig function
            const simplifiedWebpackConfig = function(config) {
              console.log('Using simplified webpack config');
              return config;
            };
            
            simplifiedWebpackConfig(simpleMockConfig);
          } catch (innerError) {
            console.log('Error with simplified webpack config:', innerError.message);
          }
        }
      } else {
        console.log('Webpack config is not a function:', typeof webpackConfig);
      }
      
      return webpackConfig;
    } catch (error) {
      console.error('Error loading webpack config:', error.message);
      console.error(error.stack);
      return null;
    }
  } catch (error) {
    console.error('Error in loadWebpackConfig:', error.message);
    console.error(error.stack);
    return null;
  }
}

module.exports = loadWebpackConfig;
