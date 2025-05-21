// Custom webpack plugin for ng-packagr
// This plugin ensures that your console.log statements run during the library build process

const { options } = require('ng-packagr/lib/ng-package-format/entry-point');
const path = require('path');

// This will run when this file is imported
console.log('Initializing Webpack configuration...');

class WebpackConfigTestPlugin {
  constructor() {
    console.log('eliran test webpack config');
  }

  apply(compiler) {
    compiler.hooks.beforeRun.tap('WebpackConfigTestPlugin', (compiler) => {
      console.log('WebpackConfigTestPlugin: Before webpack run');
    });

    compiler.hooks.afterEmit.tap('WebpackConfigTestPlugin', (compilation) => {
      console.log('WebpackConfigTestPlugin: After webpack emit');
    });
  }
}

/**
 * Customizes ng-packagr's webpack configuration
 */
function customizeWebpack(config) {
  console.log('eliran test webpack config (from customizeWebpack)');
  
  // Add our custom plugin to webpack
  config.plugins = config.plugins || [];
  config.plugins.push(new WebpackConfigTestPlugin());
  
  return config;
}

// Export hook for ng-packagr
module.exports = {
  pre: { hook: (ctx, options) => options },
  post: { hook: (ctx, options) => options },
  webpack: customizeWebpack
};
