// Custom ng-packagr transformers
const path = require('path');

/**
 * Custom ng-packagr transformation
 * This logs the initialization message and allows additional webpack customization
 */
exports.default = {
  preNgPackagr: (options) => {
    console.log('Initializing Webpack configuration...');
    return options;
  }
};
