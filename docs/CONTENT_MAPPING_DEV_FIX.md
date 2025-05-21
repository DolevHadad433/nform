# NFORM Content Mapping Development Fix

## Problem
The `nform-content-mapping.json` file was returning 404 errors when running the development server. This file is required by `ContentMapService` to load dynamic content mappings.

## Solution Implemented

1. **Modified ContentMapService**:
   - Added development environment detection based on port number
   - Used alternative path for content mapping file in development mode

2. **Created Setup Scripts**:
   - Added `setup-dev-environment.sh` script to prepare the development environment
   - Added `serve-with-content.sh` script to start the dev server with proper content mapping

3. **Updated Angular Assets Configuration**:
   - Added the mapping file to the assets configuration in `project.json`

4. **File Placement**:
   - Created a copy in `apps/nform-demo-app/src/assets/` for development server
   - Maintained the original copy in `dist/` for production builds

## How to Use

For development:
```bash
# Use the new script to start the development server
./serve-with-content.sh
```

If you encounter 404 errors for `nform-content-mapping.json` after pulling new code:
```bash
# Run the setup script to regenerate and place the files
./setup-dev-environment.sh
```

## Technical Details

- The development server uses `/assets/nform-content-mapping.json`
- The production build uses `/nform-content-mapping.json`
- The service detects which one to use based on port number (4201 indicates development)
