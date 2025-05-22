# nForm Content Structure Fix

This document outlines the solution for fixing content structure issues in the nForm application, particularly addressing:

- Placeholder content showing up in files instead of rich content
- Issues with the `ssrProccessingScript` in project.json
- 404 errors with content files like `md-contentquick-start/262c9362fd2f6e2f.json`

## Quick Start

To fix all content-related issues in one step:

```bash
./complete-build-with-content.sh
```

This comprehensive script will:
1. Build the application
2. Build the server
3. Generate the SSR processing script
4. Apply all content fixes with rich content
5. Start the content server and application server

## Available Scripts

### complete-build-with-content.sh

Complete build process with all content fixes:

```bash
./complete-build-with-content.sh
```

### run-comprehensive-content-generator.sh

Fix all content files with rich content and verify accessibility:

```bash
./run-comprehensive-content-generator.sh
```

### post-build-content-fix.sh

Fix content issues after a build has been completed:

```bash
./post-build-content-fix.sh
```

### fix-quick-start-content.sh

Fix specifically the quick-start content file:

```bash
./fix-quick-start-content.sh
```

## Content Server

The content server runs on port 4202 and serves content files. To start it:

```bash
node content-server.js > content-server.log 2>&1 &
```

## Troubleshooting

If you still see placeholder content:

1. Check if the content server is running on port 4202:
   ```bash
   lsof -i:4202
   ```

2. Verify that the quick-start content is accessible:
   ```bash
   curl -s http://localhost:4202/md-contentquick-start/262c9362fd2f6e2f.json | grep "Quick Start Guide"
   ```

3. If the correct content is served but not showing in the browser, try clearing your browser cache.

4. Run the post-build fix script:
   ```bash
   ./post-build-content-fix.sh
   ```

## Content Structure

The nForm application uses the following content structure:

```
/dist
  /md-content/                      # Primary content directory
    /guide/                         # Nested content directories
      /basics/                      # More nested directories
        nform-basics.json           # Standard content files
        ... other content files ...
    quick-start.json                # Quick start content in standard location
    ... other content files ...
  /md-contentquick-start            # Special directory for quick-start content
    262c9362fd2f6e2f.json           # Content with ID
  /md-contentguide-intro            # Special directory for guide introduction
    6024bf20223e39a0.json           # Content with ID
  ... other special directories ... 
  md-contentquick-start.json        # Direct access file
  ... other direct access files ...
  nform-content-mapping.json        # Content mapping file
```

## How It Works

The solution uses a comprehensive content generator that:

1. Reads the pages.json file to identify all required content files
2. Creates appropriate directory structures in dist/
3. Generates rich HTML content for each file
4. Creates all needed versions (standard, direct access, and special directory files)
5. Updates the content mapping appropriately

When your application requests content, the content server serves these files from the proper locations, ensuring that your users see rich content rather than placeholders.
