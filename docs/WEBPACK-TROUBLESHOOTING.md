# Webpack Common Issues in nForm

This document describes common webpack-related issues in the nForm project and their solutions.

## ENOTDIR Error with package.json Files

### Problem

When running the development server or build, you might encounter errors like:

```
Watchpack Error (initial scan): Error: ENOTDIR: not a directory, scandir '/Users/eliranbrami/projects/nform/libs/nform/package.json'
Watchpack Error (initial scan): Error: ENOTDIR: not a directory, scandir '/Users/eliranbrami/projects/nform/libs/nform/package.json/src'
```

This happens because webpack is trying to watch the package.json file as if it were a directory.

### Solution

The issue is typically caused by incorrectly requiring package.json files in webpack configurations. Instead of using `Path.join()`, use `require.resolve()` to correctly reference the package.json files.

**Example fix:**

```javascript
// Original problematic code
const nform = require(Path.join(process.cwd(), `libs/nform/package.json`));

// Fixed code
const nformPackagePath = require.resolve('../../libs/nform/package.json');
const nform = require(nformPackagePath);
```

You can run the `fix-webpack-enotdir-errors.sh` script to automatically fix these issues in your webpack configurations.

## Other Common Webpack Issues

### Content Mapping Issues

If you experience issues with content mapping, check:

1. The `NFORM_CONTENT_MAPPING_FILE` constant is properly defined in webpack.config.ts
2. The content server is running (if needed) using `start-content-server.sh`
3. Verify the `CONTENT_SERVER_URL` is correctly set in webpack.config.ts

### WebpackConstantsPlugin

The project uses a custom WebpackConstantsPlugin to define constants like `ANGULAR_VERSION`, `CDK_VERSION`, etc. If you encounter issues with undefined constants, make sure:

1. The plugin is properly included in the webpack configuration
2. The plugin is correctly reading package.json versions

## Useful Scripts

- `fix-webpack-enotdir-errors.sh`: Fixes ENOTDIR errors with package.json files
- `fix-webpack-constants.sh`: Fixes issues with the WebpackConstantsPlugin
- `optimize-webpack-content-url.js`: Optimizes webpack configuration for content server URL
- `fix-webpack-for-content.sh`: Fixes webpack configuration for content handling

## Troubleshooting

If you're experiencing webpack-related issues:

1. Check the console output for specific error messages
2. Look for watchpack errors which often indicate file path issues
3. Verify that all required plugins are properly configured
4. Make sure all paths in webpack configuration files are correctly resolved

## References

- [Webpack Documentation](https://webpack.js.org/concepts/)
- [Angular and Webpack](https://angular.io/guide/webpack)
- [Nx Documentation](https://nx.dev/)
