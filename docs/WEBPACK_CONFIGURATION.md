# Webpack Configuration for nform

## Overview

This document describes how the webpack configuration is set up in the nform project, focusing on how the webpack.config.ts file is used during both app and library builds.

## Structure

- `apps/nform-demo-app/build/webpack.config.ts` - The main webpack configuration file
- `tools/webpack-config-loader.js` - A loader that ensures webpack.config.ts is executed during library builds
- `test-webpack-config.sh` - A script to test that webpack.config.ts is loaded correctly

## How It Works

### Demo App Build

For the demo app, Angular CLI traditionally uses its own webpack configuration. The app's webpack configuration is referenced in project.json for the server-side rendering (SSR) build:

```json
"ssrWebpackConfig": "apps/nform-demo-app/build/webpack.config.ssr.js"
```

### Library Build

Library builds use ng-packagr through Nx, which has its own build process. To ensure that the console log statements in webpack.config.ts are shown during library builds, we've created a custom loader:

1. We load the webpack.config.ts file using ts-node
2. We execute the configuration function with a mock webpack config 
3. This ensures that console.log statements like "Initializing Webpack configuration..." are displayed

### Build Commands

The package.json script has been modified to use our custom loader:

```json
"build-lib": "node -r ./tools/webpack-config-loader.js -e \"require('./tools/webpack-config-loader')()\" && nx build utils --configuration production && nx build metap  --configuration production && nx build nform  --configuration production && nx build nform-material  --configuration production"
```

## Testing

You can test that the webpack configuration is loaded correctly by running:

```bash
./test-webpack-config.sh
```

Or run a clean build with:

```bash
./run-clean-build.sh
```

## Maintenance

If you add new console.log statements to webpack.config.ts, they will automatically be displayed during library builds without any changes to the setup.

If you want to modify how webpack.config.ts is loaded, edit the webpack-config-loader.js file.
