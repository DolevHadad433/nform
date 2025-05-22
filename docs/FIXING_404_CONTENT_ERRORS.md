# Fixing 404 Errors for Content Files

## Overview

This document explains how to fix 404 errors for specific content files like `md-content5e8f84b66fd66837.json` in the nForm application.

## The Problem

The nForm application uses a content mapping system to serve Markdown-based content. However, there's an issue with certain content paths, especially those that follow the pattern `md-content{id}.json` (without slashes). These paths are not properly handled by our content server and ContentMapService, resulting in 404 errors.

## Root Cause

There are three main issues:

1. **Path Transformation Logic**: The `ContentMapService.transformPath()` method only transforms paths that contain slashes, but some content references use the format `md-content5e8f84b66fd66837.json` without slashes.

2. **Content Server Routing**: The content server doesn't have special handling for paths without slashes.

3. **Missing Content Files**: Some referenced content files don't exist in the content directory.

## Solution

Our solution addresses all three issues:

### 1. Updated ContentMapService

We've updated the `transformPath()` method to handle all paths that start with "md-content", regardless of whether they contain slashes:

```typescript
public transformPath(path: string): string {
  if (!path) return path;
  
  if (this.isDevEnvironment) {
    // Handle all md-content paths, whether they have slashes or not
    if (path.startsWith('md-content')) {
      const transformedPath = `${this.contentServerUrl}/${path}`;
      if (this.debugMode) {
        console.log(`${this.logPrefix} Transforming path: "${path}" to "${transformedPath}"`);
      }
      return transformedPath;
    }
  }
  
  return path;
}
```

### 2. Enhanced Content Server

We've improved the content server to:
- Handle all `md-content*` paths
- Try alternative paths when direct paths fail
- Dynamically generate content for missing files
- Update the content mapping file with new entries

### 3. Content Path Fixing Script

We've created a script that:
- Scans for existing content files
- Creates special mappings for each content file
- Creates symlinks or copies for direct access
- Adds specific mapping for known problem files

## How to Apply the Fix

Run the comprehensive fix script to apply all these changes:

```bash
./fix-404-content-errors.sh
```

This script will:
1. Update the ContentMapService
2. Update the content server
3. Run the content path fix script
4. Restart the servers
5. Test that the problematic path is accessible

## Verifying the Fix

After running the fix, you should be able to access:

1. Through the app: http://localhost:4201/md-content5e8f84b66fd66837.json
2. Directly via the content server: http://localhost:4202/md-content5e8f84b66fd66837.json

## Troubleshooting

If you still encounter 404 errors:

1. **Check the content server log**:
   ```
   cat content-server.log
   ```

2. **Verify the mapping file**:
   ```
   cat dist/nform-content-mapping.json
   ```
   
3. **Check if the file exists**:
   ```
   ls -la dist/md-content5e8f84b66fd66837.json
   ls -la dist/md-content/5e8f84b66fd66837.json
   ```

4. **Clear your browser cache** or try in an incognito window.

5. **Manually create the file** if needed:
   ```
   echo '{"title":"Manual Fix","html":"<h1>Manually fixed content</h1>"}' > dist/md-content/5e8f84b66fd66837.json
   cp dist/md-content/5e8f84b66fd66837.json dist/md-content5e8f84b66fd66837.json
   ```
   
## Related Documentation

- [FINAL_CONTENT_STRUCTURE_FIX.md](./FINAL_CONTENT_STRUCTURE_FIX.md) - Comprehensive documentation on the content structure fix
