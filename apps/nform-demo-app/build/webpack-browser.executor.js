// Configuration for @nrwl/angular:webpack-browser executor
module.exports = {
    // Extend the base browser executor
    baseExecutor: '@angular-devkit/build-angular:browser',

    // Additional configuration options
    options: {
        // Use our custom webpack config
        customWebpackConfig: {
            path: './apps/nform-demo-app/build/custom-webpack.config.js'
        }
    },

    // Executor implementation
    implementationFactory: () => {
        // Load the executor
        const executor = require('@nrwl/angular/src/executors/webpack-browser/webpack-browser.impl');

        // Return a wrapped executor function
        return async (options, context) => {
            console.log('Running custom webpack executor for content structure fix');

            // Set the content mapping file environment variable
            process.env.NFORM_CONTENT_MAPPING_FILE = 'nform-content-mapping.json';

            // Run the executor with our options
            return executor(options, context);
        };
    }
};
