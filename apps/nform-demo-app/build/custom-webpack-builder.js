// Custom Angular builder to wrap the standard browser builder with our webpack config
const { BuilderContext, createBuilder } = require('@angular-devkit/architect');
const { executeBrowserBuilder } = require('@angular-devkit/build-angular');
const fs = require('fs');
const path = require('path');

// Log with prefix for easy identification
function log(message) {
    console.log(`[CustomBuilder] ${message}`);
}

// Load the webpack plugin at runtime
function loadWebpackPlugin() {
    const pluginPath = path.resolve(__dirname, '../../tools/fix-content-structure-plugin.js');
    if (fs.existsSync(pluginPath)) {
        return require(pluginPath);
    } else {
        log(`Warning: Could not find webpack plugin at ${pluginPath}`);
        return null;
    }
}

// Create and return the builder
exports.default = createBuilder((options, context) => {
    log('Starting custom build with content structure fix');

    // Save original options for later
    const originalOptions = { ...options };

    // Extend the webpack configuration
    options.customWebpackConfig = {
        path: path.resolve(__dirname, 'webpack.content.js')
    };

    // Add extra webpack configuration to modify the standard build
    if (!fs.existsSync(path.resolve(__dirname, 'webpack.content.js'))) {
        log('Creating webpack.content.js configuration');

        // Create the webpack config file if it doesn't exist
        const webpackConfigContent = `
const path = require('path');

module.exports = (config) => {
  console.log('[ContentFix] Applying content structure fix to webpack config');
  
  // Load the plugin
  const FixContentStructurePlugin = require('../../tools/fix-content-structure-plugin');
  
  // Add our plugin to the webpack config
  if (!config.plugins) {
    config.plugins = [];
  }
  
  config.plugins.push(new FixContentStructurePlugin({
    pagesJsonPath: 'md-content/pages.json',
    generateContentFiles: true
  }));
  
  return config;
};`;

        fs.writeFileSync(path.resolve(__dirname, 'webpack.content.js'), webpackConfigContent);
        log('Created webpack.content.js configuration');
    }

    // Execute the browser builder with our custom webpack configuration
    log('Executing browser builder with content fix');
    return executeBrowserBuilder(options, context);
});
