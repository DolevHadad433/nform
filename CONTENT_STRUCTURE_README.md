# nForm Content Structure Fix

This directory contains a complete solution for fixing content structure issues in the nForm application, particularly addressing:

- 404 errors with content files like `md-content5e8f84b66fd66837.json`
- Content files containing placeholder text instead of rich HTML content
- Proper content mapping for various access patterns

## Quick Start Guide

### Fixing All Content Issues

To fix all content-related issues in one step:

```bash
./fix-all-content-issues.sh
```

### Starting the Application with Content Checks

To start the application with automatic content verification:

```bash
./start-app-with-content-check.sh
```

### Generating Rich Content Only

If you only need to regenerate content files:

```bash
./generate-rich-content.sh
```

## Available Scripts

| Script | Purpose |
|--------|---------|
| `fix-all-content-issues.sh` | All-in-one script that fixes all content-related issues |
| `start-app-with-content-check.sh` | Starts the app with automatic content verification |
| `generate-rich-content.sh` | Generate all content files and verify access |
| `content-server.js` | Serve content files on port 4202 |

## Common Issues

1. **404 Errors for Content Files**: Run `./fix-all-content-issues.sh`
2. **Placeholder Content**: Run `./generate-rich-content.sh`
3. **Content Server Not Running**: Run `node content-server.js`

## Detailed Documentation

For a comprehensive guide on content structure and all available solutions, refer to:

[NFORM_CONTENT_COMPREHENSIVE_GUIDE.md](docs/NFORM_CONTENT_COMPREHENSIVE_GUIDE.md)

## Content Server

The content server runs on port 4202 and serves files from the `dist` directory.

## Maintenance

- Always run `generate-rich-content.sh` after pulling new code
- If new content files are added, update the templates in `generate-rich-content.js`
- Keep the content server running on port 4202 during development
- Check `content-server.log` for any errors in content serving
