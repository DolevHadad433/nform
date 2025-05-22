# Webpack Constants Fix

This document explains how we fixed the issue with webpack-defined constants like `ANGULAR_VERSION`, `CDK_VERSION`, `NFORM_VERSION`, and `BUILD_VERSION` not being properly defined during the build process.

## Problem

The application was encountering runtime errors with messages like:

```
ERROR Error: Uncaught (in promise): ReferenceError: ANGULAR_VERSION is not defined
```

These constants are supposed to be defined by webpack's DefinePlugin during the build process, but they were not being properly injected into the compiled code.

## Root Cause

The root cause of this issue is similar to the content mapping issue. The webpack configuration in `apps/nform-demo-app/build/webpack.config.ts` defines these constants using webpack's DefinePlugin, but this configuration is only applied during the demo app build, not during the library build.

Additionally, the AsyncDefinePlugin was being used, which might not execute correctly in all build scenarios.

## Solution

We implemented a comprehensive solution with multiple fallback mechanisms:

1. Created a dedicated webpack plugin (`WebpackConstantsPlugin`) that properly defines the constants during build time
2. Generated a fallback JSON file that can be imported if the constants aren't defined
3. Added runtime checks in components that use these constants to provide default values if they're not defined

### Implementation Details

#### 1. WebpackConstantsPlugin

We created a custom webpack plugin at `tools/webpack-constants-plugin.js` that:
- Extracts version information from package.json
- Uses webpack's DefinePlugin to define global constants
- Generates a fallback JSON file that can be imported if needed

#### 2. Integration with Build Process

We've updated the webpack configuration to use this plugin, and created scripts to ensure the constants are properly defined:

- `fix-webpack-constants.sh`: Sets up the plugin and generates fallback JSON
- `build-with-constants.sh`: Runs the fix script and then builds the application
- `test-webpack-constants.sh`: Tests if the constants are properly defined

#### 3. Component Updates

We've updated components that use these constants to:
- Check if the constants are defined at runtime
- Fall back to imported JSON values if not defined
- Provide hardcoded default values as a last resort

## Usage

### For Developers

If you encounter webpack constant issues, you can:

1. Run `./fix-webpack-constants.sh` to generate the fallback JSON file
2. Run `./build-with-constants.sh` to build with the constants properly defined

### For Component Developers

When using these constants in components, follow this pattern:

```typescript
// Try to use webpack-defined constants, fallback to imported values or defaults
private constants = getVersionConstants();
ngVersion = typeof ANGULAR_VERSION !== 'undefined' ? ANGULAR_VERSION : this.constants.angular;
```

## Testing

You can test if the constants are properly defined by running:

```
./test-webpack-constants.sh
```

This will show the contents of the fallback JSON file and verify that it's accessible.

## Related Issues

This fix is similar to the content mapping fix documented in:
- [NFORM_CONTENT_MAPPING_ISSUE.md](./NFORM_CONTENT_MAPPING_ISSUE.md)
- [WEBPACK_CONFIGURATION.md](./WEBPACK_CONFIGURATION.md)
