/**
 * Custom webpack configuration for nform content structure
 * To be used with @nrwl/angular:webpack-browser executor
 */
const path = require('path');
const FixContentStructurePlugin = require('../../tools/fix-content-structure-plugin');
const ContentMappingFilesPlugin = require('../../tools/content-mapping-files-plugin');
const WebpackConstantsPlugin = require('../../tools/webpack-constants-plugin');

module.exports = (config, options) => {
    console.log('Applying content structure fixes to webpack config...');

    if (!config.plugins) {
        config.plugins = [];
    }

    // Add the content structure fix plugin
    config.plugins.push(new FixContentStructurePlugin({
        pagesJsonPath: 'md-content/pages.json',
        generateContentFiles: true
    }));

    // Add the content mapping files plugin
    config.plugins.push(new ContentMappingFilesPlugin());

    // Add the webpack constants plugin for version information
    config.plugins.push(new WebpackConstantsPlugin());

    console.log('Content structure fix plugins added to webpack config');

    // Define NFORM_CONTENT_MAPPING_FILE for use throughout the application
    process.env.NFORM_CONTENT_MAPPING_FILE = 'nform-content-mapping.json';

    return config;
};
