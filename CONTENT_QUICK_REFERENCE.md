# nForm Content Quick Reference

## Common Commands

### Generate Content & Start Content Server

```bash
./run-comprehensive-content-generator.sh
```

### Start App with Content Quality Check

```bash
./start-app-with-advanced-content-check.sh
```

### Full Build with Content Generation

```bash
./complete-build-with-content.sh
```

### Check Content Accessibility

```bash
# Check Quick Start content
curl -s "http://localhost:4202/md-contentquick-start/262c9362fd2f6e2f.json" | grep -o '"title".*'

# Check Guide Introduction content
curl -s "http://localhost:4202/md-contentguide-intro/6024bf20223e39a0.json" | grep -o '"title".*'
```

## Content Server

The content server runs on port 4202. To check if it's running:

```bash
lsof -i:4202
```

To restart it:

```bash
# Kill existing server
pkill -f "node content-server.js"

# Start new server
node content-server.js > content-server.log 2>&1 &
```

## Troubleshooting

### Placeholder Content Appears

1. Verify content server is running on port 4202
2. Regenerate content with `./run-comprehensive-content-generator.sh`
3. Check the content is accessible via curl
4. Clear browser cache and reload

### 404 Errors for Content

1. Check `nform-content-mapping.json` to ensure the path is properly mapped
2. Verify the file exists in the correct location in `dist/`
3. Regenerate content files to fix any missing ones

### Adding New Content

1. Add the path to `pages.json` in the `entryData` section
2. Add a template to `comprehensive-content-generator.js` if specific content is needed
3. Run `./run-comprehensive-content-generator.sh`

## Reference Files

- Comprehensive guide: [NFORM_CONTENT_SOLUTION.md](NFORM_CONTENT_SOLUTION.md)
- Content fix guide: [CONTENT_FIX_GUIDE.md](CONTENT_FIX_GUIDE.md)
- Content generator: [comprehensive-content-generator.js](comprehensive-content-generator.js)
