/**
 * Script to update webpack configuration to ensure proper content server URL handling
 */
const fs = require('fs');
const path = require('path');

// Configuration
const WEBPACK_CONFIG_PATH = path.join(__dirname, 'apps', 'nform-demo-app', 'build', 'webpack.config.ts');
const CONTENT_MAP_SERVICE_PATH = path.join(__dirname, 'apps', 'libs', 'shared', 'lib', 'services', 'content-map.service.ts');

// Check if files exist
if (!fs.existsSync(WEBPACK_CONFIG_PATH)) {
    console.error(`Webpack config not found at: ${WEBPACK_CONFIG_PATH}`);
    process.exit(1);
}

if (!fs.existsSync(CONTENT_MAP_SERVICE_PATH)) {
    console.error(`ContentMapService not found at: ${CONTENT_MAP_SERVICE_PATH}`);
    process.exit(1);
}

// Read webpack config
let webpackConfig = fs.readFileSync(WEBPACK_CONFIG_PATH, 'utf8');

// Ensure CONTENT_SERVER_URL is properly defined and passed to DefinePlugin
if (!webpackConfig.includes('CONTENT_SERVER_URL')) {
    console.log('Adding CONTENT_SERVER_URL to webpack configuration...');

    // Update the environment variables section
    webpackConfig = webpackConfig.replace(
        /const NFORM_CONTENT_MAPPING_FILE = process\.env\.NFORM_CONTENT_MAPPING_FILE \|\| 'nform-content-mapping\.json';/,
        `const NFORM_CONTENT_MAPPING_FILE = process.env.NFORM_CONTENT_MAPPING_FILE || 'nform-content-mapping.json';\n  const CONTENT_SERVER_URL = process.env.CONTENT_SERVER_URL || 'http://localhost:4202';\n  console.log('Using content server URL:', CONTENT_SERVER_URL);`
    );

    // Make sure it's included in the DefinePlugin
    webpackConfig = webpackConfig.replace(
        /NFORM_CONTENT_MAPPING_FILE: JSON\.stringify\(NFORM_CONTENT_MAPPING_FILE\),/,
        `NFORM_CONTENT_MAPPING_FILE: JSON.stringify(NFORM_CONTENT_MAPPING_FILE),\n      CONTENT_SERVER_URL: JSON.stringify(CONTENT_SERVER_URL),`
    );

    // Write updated webpack config
    fs.writeFileSync(WEBPACK_CONFIG_PATH, webpackConfig);
    console.log('Webpack config updated successfully');
} else {
    console.log('CONTENT_SERVER_URL already defined in webpack configuration');
}

// Read ContentMapService
let contentMapService = fs.readFileSync(CONTENT_MAP_SERVICE_PATH, 'utf8');

// Ensure ContentMapService can use CONTENT_SERVER_URL from environment
if (!contentMapService.includes('declare const CONTENT_SERVER_URL')) {
    console.log('Updating ContentMapService to use CONTENT_SERVER_URL from environment...');

    // Add constant declaration
    contentMapService = contentMapService.replace(
        /declare const NFORM_CONTENT_MAPPING_FILE: string;/,
        `declare const NFORM_CONTENT_MAPPING_FILE: string;\ndeclare const CONTENT_SERVER_URL: string;`
    );

    // Update content server URL initialization
    contentMapService = contentMapService.replace(
        /private contentServerUrl = this\.isDevEnvironment \? 'http:\/\/localhost:4202' : '';/,
        `private contentServerUrl = this.isDevEnvironment ? (typeof CONTENT_SERVER_URL !== 'undefined' ? CONTENT_SERVER_URL : 'http://localhost:4202') : '';`
    );

    // Write updated ContentMapService
    fs.writeFileSync(CONTENT_MAP_SERVICE_PATH, contentMapService);
    console.log('ContentMapService updated successfully');
} else {
    console.log('ContentMapService already using CONTENT_SERVER_URL');
}

console.log('All content server URL updates completed successfully');
