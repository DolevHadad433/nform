# nForm Content Structure Solution

This directory contains scripts and tools to fix content structure issues in the nForm application, ensuring that all content files are properly accessible and contain rich content.

## Key Scripts

- **`fix-all-content-issues.sh`**: All-in-one solution that fixes all content structure issues
- **`start-app-with-content-check.sh`**: Starts the app with automatic content verification
- **`generate-rich-content.sh`**: Generates all content files with rich content

## Common Issues Addressed

1. 404 errors for content files like `md-content5e8f84b66fd66837.json`
2. Placeholder content instead of rich HTML content
3. Content mapping issues

## Quick Start

Run the all-in-one fix script:

```bash
./fix-all-content-issues.sh
```

Then start the application with content verification:

```bash
./start-app-with-content-check.sh
```

## Detailed Documentation

For a comprehensive guide to the content structure solution, see:

[NFORM_CONTENT_COMPREHENSIVE_GUIDE.md](docs/NFORM_CONTENT_COMPREHENSIVE_GUIDE.md)

## Content Structure

The solution creates a content structure as follows:

```
/dist
  /md-content/                       # Content directory with .json files
  md-content*.json                   # Direct access files
  nform-content-mapping.json         # Content mapping file
```

## Content Server

A separate content server runs on port 4202 to serve content files. The `ContentMapService` transforms paths to use this server in development mode.

## Maintenance

After pulling new code or adding new content files, run:

```bash
./generate-rich-content.sh
```

To update content templates, edit the `realContentTemplates` object in `generate-rich-content.js`.
