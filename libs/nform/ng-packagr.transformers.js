// Custom ng-packagr transformers
const path = require('path');

/**
 * A custom transformer for ng-packagr
 */
function customTransformer() {
  return (options) => {
    console.log('Initializing Webpack configuration...');
    return options;
  };
}

module.exports = {
  pre: [customTransformer()]
};
