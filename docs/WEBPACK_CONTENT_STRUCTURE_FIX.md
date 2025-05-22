# Webpack Content Structure Fix for nForm Demo App

This document explains the comprehensive fix for the webpack content structure issues in the nForm demo app.

## The Problem

The webpack build process was not creating the correct content structure in `pages.json` for the nForm demo app. The issues included:

1. Incorrect path formats in the `entryData` object
2. Missing navigation structure properties
3. Invalid JSON file references
4. Content files not being generated correctly

## The Solution

The solution includes several components:

### 1. Custom Webpack Plugin

A custom webpack plugin (`FixContentStructurePlugin`) was created to:
- Intercept the output of the markdown pages webpack plugin
- Fix the structure of `pages.json`
- Generate missing content files

### 2. Custom Webpack Config

A custom webpack configuration wrapper was created to apply the plugin during the build process.

### 3. Content File Generator

An improved content file generator script was created to ensure all referenced files exist.

### 4. Content Server

A standalone content server was implemented to serve JSON files on port 4202.

### 5. ContentMapService Updates

The `ContentMapService` was updated to:
- Use port 4202 for the content server
- Transform paths for correct content loading

## How to Use

1. Run the build with fixed content structure:
   ```
   ./build-with-fixed-content.sh
   ```

2. This will:
   - Update the webpack configuration
   - Build the app with the fixed content structure
   - Generate all necessary content files
   - Start the content server

3. Start the application:
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

### Content Server

The content server runs on port 4202 and serves files from the `dist` directory.

### Path Transformation

The `ContentMapService` transforms paths to use the content server for special paths:

```typescript
public transformPath(path: string): string {
  if (this.isDevEnvironment && path) {
    if (path.startsWith('md-content') && path.includes('/')) {
      return `${this.contentServerUrl}/${path}`;
    }
  }
  return path;
}
```

## Troubleshooting

If you encounter issues with the content not loading:

1. Check that the content server is running on port 4202
2. Verify that ContentMapService is using port 4202
3. Check the browser console for 404 errors
4. Run the content file generator again:
   ```
   node generate-content-files-improved.js
   ```

## Future Improvements

For a more permanent solution:

1. Modify the webpack markdown pages plugin to generate the correct structure directly
2. Integrate the content file generation into the build process
3. Add validation to ensure all referenced files exist
