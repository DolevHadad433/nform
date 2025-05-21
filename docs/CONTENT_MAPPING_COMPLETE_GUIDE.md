# Content Mapping Files Fix Documentation

## Problem Summary

The application was experiencing 404 errors when trying to access:
- `/nform-content-mapping.json`
- Referenced files: `/md-content/pages.json`, `/md-content/code-examples.json`, and `/md-content/search-content.json`

## Root Causes

1. **File Location Issues**: The content mapping files were being generated in the `dist/` directory, but the development server wasn't configured to serve these files.

2. **Asset Configuration**: The Angular application assets configuration didn't properly include the content mapping files.

3. **Path Resolution**: The `ContentMapService` wasn't handling different environments (development vs production) correctly.

## Solution Implemented

Our solution addressed all aspects of the problem:

### 1. File Placement
- Content mapping files are now generated and placed in multiple strategic locations:
  - `dist/` directory (for production builds)
  - `apps/nform-demo-app/src/` directory (for direct serving in development)
  - `.nx/cache/dev-server/nform-demo-app/` (for Angular CLI dev server)

### 2. Angular Configuration
- Updated `project.json` to include content mapping files in the assets configuration:
```json
"assets": [
  "apps/nform-demo-app/src/nform-content-mapping.json",
  "apps/nform-demo-app/src/md-content",
  // ...other assets
  {
    "glob": "nform-content-mapping.json",
    "input": "dist",
    "output": "/"
  },
  {
    "glob": "**/*",
    "input": "dist/md-content",
    "output": "/md-content"
  }
]
```

### 3. Service Enhancement
- Enhanced `ContentMapService` with:
  - Development environment detection based on port number
  - Dynamic path selection based on environment
  - Debug logging to track file loading

## Usage Instructions

If you encounter 404 errors related to content mapping files, use one of these scripts:

### Basic Fix
```bash
# Apply the basic fix and restart the server
./fix-content-mapping-final.sh
nx serve nform-demo-app
```

### With Debugging
If you need to diagnose issues further:
```bash
# Apply the fix and run with debugging output
./fix-content-mapping-final.sh
# Check browser console for ContentMapService logs
```

## Verification

You can verify the fix is working by accessing:
- Main mapping file: `http://localhost:4201/nform-content-mapping.json`
- Content files: `http://localhost:4201/md-content/pages.json`

## How It Works

1. **Development Environment**:
   - Files are served directly from the source directory
   - The service detects development mode (port 4201)
   - Paths are adjusted automatically

2. **Production Environment**:
   - Files are properly included in the build output
   - The webpack-injected constant `NFORM_CONTENT_MAPPING_FILE` is used

## Maintenance Notes

When making changes to content structure:
1. Update the `nform-content-mapping.json` schema if needed
2. Run the fix script to regenerate content files
3. Restart the development server

## Related Files
- `apps/libs/shared/lib/services/content-map.service.ts` - Service handling content mapping
- `apps/nform-demo-app/project.json` - Asset configuration
- `tools/generate-content-mapping.js` - Content generation script
- `fix-content-mapping-final.sh` - Comprehensive fix script
