/**
 * Webpack plugin to ensure constants are defined
 * This plugin adds global constants like ANGULAR_VERSION, CDK_VERSION, etc. to the build
 */
const webpack = require('webpack');
const path = require('path');
const fs = require('fs');

class WebpackConstantsPlugin {
    constructor(options = {}) {
        // Default options
        this.options = Object.assign(
            {
                outputFile: 'webpack-constants.json',
                createFallbackFile: true,
            },
            options
        );

        // Get package.json to determine versions
        const packageJsonPath = path.resolve(process.cwd(), 'package.json');
        this.packageJson = require(packageJsonPath);
    }

    apply(compiler) {
        const pluginName = 'WebpackConstantsPlugin';

        // Generate the constants object
        const constants = this.getConstants();

        // Create a define plugin to add global constants
        const definePlugin = new webpack.DefinePlugin({
            ANGULAR_VERSION: JSON.stringify(constants.ANGULAR_VERSION),
            CDK_VERSION: JSON.stringify(constants.CDK_VERSION),
            NFORM_VERSION: JSON.stringify(constants.NFORM_VERSION),
            BUILD_VERSION: JSON.stringify(constants.BUILD_VERSION),
        });

        // Apply the define plugin
        definePlugin.apply(compiler);

        // Write constants to a JSON file for fallback
        if (this.options.createFallbackFile) {
            compiler.hooks.afterEmit.tapAsync(pluginName, (compilation, callback) => {
                const outputPath = compilation.outputOptions.path;
                if (!outputPath) {
                    console.warn(`[${pluginName}] Output path not available, skipping fallback file creation`);
                    return callback();
                }

                const outputFile = path.resolve(outputPath, this.options.outputFile);

                // Create directory if it doesn't exist
                const outputDir = path.dirname(outputFile);
                if (!fs.existsSync(outputDir)) {
                    fs.mkdirSync(outputDir, { recursive: true });
                }

                // Write the constants to a JSON file
                fs.writeFile(outputFile, JSON.stringify(constants, null, 2), (err) => {
                    if (err) {
                        console.error(`[${pluginName}] Error writing constants file:`, err);
                    } else {
                        console.log(`[${pluginName}] Generated constants file at ${outputFile}`);
                    }
                    callback();
                });
            });
        }
    }

    getConstants() {
        // Extract versions from package.json
        const angularVersion = (this.packageJson.dependencies['@angular/core'] || '').replace('^', '');
        const cdkVersion = (this.packageJson.dependencies['@angular/cdk'] || '').replace('^', '');
        const nformVersion = this.packageJson.version || '1.0.0';

        // Get git info if available
        let buildVersion = 'dev';
        try {
            // Get date-based version if git not available
            buildVersion = `dev-${new Date().toISOString().slice(0, 10)}`;
        } catch (err) {
            console.warn('[WebpackConstantsPlugin] Could not get git info:', err.message);
        }

        return {
            ANGULAR_VERSION: angularVersion || '16.1.0',
            CDK_VERSION: cdkVersion || '16.1.0',
            NFORM_VERSION: nformVersion,
            BUILD_VERSION: buildVersion,
        };
    }
}

module.exports = WebpackConstantsPlugin;
