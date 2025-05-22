# Fixing Webpack Content Structure in nForm Demo App

## Problem

The nForm demo app had an issue with webpack not creating the correct content structure in pages.json. The issues included:

1. Incorrect path formats in the `entryData` object
2. Missing navigation structure properties like "tooltip" and "searchGroup"
3. Invalid JSON file references that couldn't be accessed
4. Home page path was "home" instead of "/"
5. Content files weren't being generated properly

## Solution

We've implemented a comprehensive solution that includes:

1. **Custom Webpack Plugin**: A plugin that fixes the content structure during build
2. **Custom Angular Builder**: An Angular builder that integrates our plugin
3. **Content File Generator**: A script to generate all missing content files
4. **Content Server**: A standalone Express server that serves the JSON files
5. **Updated ContentMapService**: Modifications to route requests to the content server

## Implementation Files

The solution consists of the following key files:

1. **fix-webpack-for-content.sh** - Sets up the foundation for the fix
2. **tools/fix-content-structure-plugin.js** - Webpack plugin to fix the content structure
3. **apps/nform-demo-app/build/custom-webpack-builder.js** - Custom Angular builder
4. **generate-content-files-improved.js** - Script to generate missing content files
5. **update-project-for-custom-builder.sh** - Updates the project to use the custom builder
6. **build-with-custom-builder.sh** - Builds the app with the fixed content structure
7. **content-server.js** - Express server to serve the content files

## How to Use

### Option 1: Quick Fix for Development

If you just need the content to work for development:

1. Run the content server:
   ```
   ./start-content-server.sh
   ```

2. Make sure ContentMapService is using port 4202:
   ```typescript
   private contentServerUrl = this.isDevEnvironment ? 'http://localhost:4202' : '';
   ```

3. Serve the app:
   ```
   npm run start
   ```

### Option 2: Permanent Fix (Recommended)

For a permanent solution that modifies the build process:

1. Set up the fix:
   ```
   ./fix-webpack-for-content.sh
   ```

2. Build with the custom builder:
   ```
   ./build-with-custom-builder.sh
   ```

3. Serve the app:
   ```
   npm run start
   ```

## Technical Details

### Content Structure Format

The correct structure for `pages.json` is:

```json
{
  "entries": {
    "/": {
      "title": "Home",
      "path": "/",
      "type": "index"
    },
    "guide": {
      "title": "Guide",
      "path": "guide",
      "type": "topMenuSection",
      "tooltip": "How-to Guide",
      "searchGroup": "guide",
      "children": [...]
    }
  },
  "entryData": {
    "guide-introduction": "md-content/guide-introduction.json",
    "guide-basics-nform-basics": "md-content/guide-basics-nform-basics.json"
  }
}
```

### Custom Webpack Plugin

The plugin intercepts the webpack build process and:

1. Modifies the structure of pages.json
2. Ensures all entries have the correct attributes
3. Fixes the paths in entryData to use the correct format
4. Generates content files for all entries in entryData

### Custom Angular Builder

The custom builder extends Angular's standard browser builder and:

1. Loads our webpack plugin
2. Applies it to the webpack config
3. Executes the standard build process with our modifications

### Content Server

The content server:

1. Runs on port 4202
2. Serves files from the dist directory
3. Provides special handling for content files

### ContentMapService

The ContentMapService was updated to:

1. Detect development environment
2. Transform paths to use the content server
3. Handle special paths like "md-content/*"

## Troubleshooting

If you encounter issues:

1. **Content not loading**: 
   - Check that the content server is running
   - Verify ContentMapService is using port 4202
   - Check the browser console for 404 errors

2. **Build failing**:
   - Check that all scripts are executable (`chmod +x script_name.sh`)
   - Verify that the project.json has been updated correctly
   - Check the build logs for errors

3. **Missing content files**:
   - Run the content file generator script
   - Check if the files exist in the dist/md-content directory

## Future Improvements

For an even more permanent solution:

1. Integrate the fix into the webpack-markdown-pages plugin
2. Add validation to ensure all referenced files exist
3. Improve error handling and reporting
4. Create a proper Angular schematic for the custom builder
