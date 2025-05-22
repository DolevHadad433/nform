# Webpack Content Structure Comprehensive Fix

## Overview

This document provides a comprehensive solution to fix the webpack content structure issues in the nForm demo app. These issues were causing problems with:

1. Content file generation
2. Path formats in content files
3. Navigation properties
4. 404 errors when trying to load content

## The Solution

Our final solution involves several key components:

### 1. Updated Project Configuration

We removed the deprecated `webpackConfig` property from `project.json` as it was causing schema validation errors in Angular 16.1.0. Instead, we use a custom webpack configuration approach that's compatible with the latest Angular versions.

### 2. Custom Webpack Configuration

We created a streamlined custom webpack configuration file at `apps/nform-demo-app/build/custom-webpack.config.js` that:

- Uses the `FixContentStructurePlugin` to fix issues with content structure
- Uses the `ContentMappingFilesPlugin` to handle content mapping
- Uses the `WebpackConstantsPlugin` to manage version constants
- Properly sets the `NFORM_CONTENT_MAPPING_FILE` environment variable

### 3. Content Server

We use a dedicated content server running on port 4202 to serve content files from the `dist` directory, which fixes path issues and 404 errors.

### 4. ContentMapService

We updated the `ContentMapService` to use port 4202 consistently for content file URLs in development mode.

### 5. Improved Webpack Constants

We updated the webpack.config.ts file to ensure all necessary constants are properly defined:
- NFORM_CONTENT_MAPPING_FILE
- ANGULAR_VERSION
- CDK_VERSION 
- NFORM_VERSION
- BUILD_VERSION

### 6. Single Execution Script

We created an all-in-one script `fix-all-webpack-issues.sh` that:

1. Stops any running servers
2. Fixes the project.json configuration
3. Updates webpack.config.ts with the correct constants
4. Sets up the correct environment variables
5. Cleans build caches
6. Builds the application with the fixed webpack configuration
7. Generates content files
8. Starts the content server
9. Verifies the content server
10. Starts the application server

## How to Use

To apply the fix and run the application:

```bash
# Make the script executable (if not already)
chmod +x fix-all-webpack-issues.sh

# Run the fix and start the servers
./fix-all-webpack-issues.sh
```

This will:
1. Build the application with the correct content structure
2. Start the content server on port 4202
3. Start the application server on port 4201

## Troubleshooting

### If You Need to Roll Back

If you encounter issues with the fix and need to revert to the previous configuration:

```bash
# Make the rollback script executable
chmod +x rollback-webpack-fixes.sh

# Run the rollback script
./rollback-webpack-fixes.sh
```

This will:
1. Stop any running servers
2. Restore the original configuration if desired
3. Clean up generated files
4. Clear Angular cache

### Common Issues and Solutions

1. **Content files not loading**
   - Check that the content server is running on port 4202
   - Verify that the `nform-content-mapping.json` file exists in the `dist` directory
   - Confirm that the `md-content` directory exists in the `dist` directory

2. **Version constants undefined**
   - Check that WebpackConstantsPlugin is properly added to webpack.config.ts
   - Ensure the DefinePlugin in AsyncDefinePlugin is returning all constants

3. **Build fails with schema validation errors**
   - Ensure the `webpackConfig` property is removed from project.json
   - Check that only the `ssrWebpackConfig` property remains

4. **404 errors when navigating**
   - Ensure the content server is running
   - Check that ContentMapService is using the correct port (4202)
   - Verify the environment detection is working correctly

## Technical Details

### Content Structure Plugin

The `FixContentStructurePlugin` fixes content structure issues by:

1. Modifying the `pages.json` file to have the correct structure
2. Ensuring all entries have the required attributes
3. Fixing the paths in `entryData` to use the correct format
4. Generating content files for all entries

### Content Server

The content server runs on port 4202 and:

1. Serves files from the `dist` directory
2. Provides special handling for content files in the `md-content` directory
3. Resolves path issues that were causing 404 errors

### ContentMapService

The ContentMapService:

1. Detects if the application is running in development mode
2. Uses the content server URL (http://localhost:4202) for content files in dev mode
3. Transforms paths to ensure they are correctly formatted for both dev and prod

## Related Documentation

- [WEBPACK_CONFIGURATION.md](./WEBPACK_CONFIGURATION.md) - Documentation on webpack configuration
- [WEBPACK_CONSTANTS_FIX.md](./WEBPACK_CONSTANTS_FIX.md) - Documentation on fixing webpack constants
# Make the script executable
chmod +x fix-content-structure.sh

# Run the fix and start the servers
./fix-content-structure.sh
```

This will:
1. Build the application with the correct content structure
2. Start the content server on port 4202
3. Start the application server on port 4201

## Technical Details

### Content Structure Plugin

The `FixContentStructurePlugin` fixes content structure issues by:

1. Modifying the `pages.json` file to have the correct structure
2. Ensuring all entries have the required attributes
3. Fixing the paths in `entryData` to use the correct format
4. Generating content files for all entries

### Content Mapping Files Plugin

The `ContentMappingFilesPlugin` handles content mapping by:

1. Creating the correct mapping between content IDs and file paths
2. Generating the `nform-content-mapping.json` file with the correct structure
3. Ensuring content files are properly referenced

### Content Server

The content server runs on port 4202 and:

1. Serves files from the `dist` directory
2. Provides special handling for content files in the `md-content` directory
3. Resolves path issues that were causing 404 errors

## Troubleshooting

If you encounter issues:

1. Make sure both the content server (port 4202) and application server (port 4201) are running
2. Check that the `nform-content-mapping.json` file exists in the `dist` directory
3. Verify that the `md-content` directory exists in the `dist` directory and contains the content files
4. Check the console for any error messages related to content loading

## Related Documentation

- [WEBPACK_CONFIGURATION.md](./WEBPACK_CONFIGURATION.md) - Documentation on webpack configuration
- [WEBPACK_CONSTANTS_FIX.md](./WEBPACK_CONSTANTS_FIX.md) - Documentation on fixing webpack constants
