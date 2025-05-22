/**
 * Script to generate all content files based on the paths in pages.json
 * This creates rich content for every page in the application
 */
const fs = require('fs');
const path = require('path');

// Configuration
const DIST_DIR = path.join(__dirname, 'dist');
const CONTENT_DIR = path.join(DIST_DIR, 'md-content');
const PAGES_FILE_PATH = path.join(CONTENT_DIR, 'pages.json');
const MAPPING_FILE_PATH = path.join(DIST_DIR, 'nform-content-mapping.json');

// Import the template content from generate-rich-content.js
const { realContentTemplates } = require('./generate-rich-content-templates');

console.log('Generating comprehensive content for all pages...');

// Ensure necessary directories exist
if (!fs.existsSync(DIST_DIR)) {
    fs.mkdirSync(DIST_DIR, { recursive: true });
}

if (!fs.existsSync(CONTENT_DIR)) {
    fs.mkdirSync(CONTENT_DIR, { recursive: true });
}

// Load pages.json to get all content paths
if (!fs.existsSync(PAGES_FILE_PATH)) {
    console.error(`Pages file not found: ${PAGES_FILE_PATH}`);
    console.log('Make sure to run the build process first to generate pages.json');
    process.exit(1);
}

// Read pages.json
let pages;
try {
    pages = JSON.parse(fs.readFileSync(PAGES_FILE_PATH, 'utf8'));
    console.log('Loaded pages configuration successfully');
} catch (error) {
    console.error(`Error parsing pages file: ${error.message}`);
    process.exit(1);
}

// Extract all paths from pages.json
const contentPaths = extractContentPaths(pages);
console.log(`Found ${contentPaths.length} content paths in pages.json`);

// Load existing content mapping
let mapping = {};
if (fs.existsSync(MAPPING_FILE_PATH)) {
    try {
        mapping = JSON.parse(fs.readFileSync(MAPPING_FILE_PATH, 'utf8'));
        console.log('Loaded existing content mapping');
    } catch (error) {
        console.error(`Error parsing mapping file: ${error.message}`);
        console.log('Creating new mapping file');
    }
}

// Process and generate content for each path
contentPaths.forEach(contentInfo => {
    createContentFile(contentInfo.path, contentInfo.id);
});

// Save updated mapping
fs.writeFileSync(MAPPING_FILE_PATH, JSON.stringify(mapping, null, 2));
console.log(`Updated mapping file saved to ${MAPPING_FILE_PATH}`);

console.log('Content generation for all pages completed');

// Function to extract content paths from pages.json
function extractContentPaths(pages) {
    const contentPaths = [];

    // Add root path
    contentPaths.push({ path: '/', id: null });

    // Process entryData to get all content paths and their IDs
    if (pages.entryData) {
        Object.entries(pages.entryData).forEach(([path, contentPath]) => {
            // Handle different content path formats
            let id = null;

            // Extract ID from paths like "md-contentguide-intro/6024bf20223e39a0.json"
            const idMatch = contentPath.match(/md-content[^\/]*\/([a-f0-9]+)\.json/);
            if (idMatch) {
                id = idMatch[1];
            }

            contentPaths.push({ path, id });
        });
    }

    // Also add paths from entries
    if (pages.entries) {
        processEntries(pages.entries, contentPaths);
    }

    return contentPaths;
}

// Recursively process entries to extract paths
function processEntries(entries, contentPaths) {
    Object.entries(entries).forEach(([key, entry]) => {
        if (entry.path && entry.path !== '/') {
            // Add the entry path if it's not already in the list
            if (!contentPaths.some(item => item.path === entry.path)) {
                contentPaths.push({ path: entry.path, id: null });
            }
        }

        // Process children recursively
        if (entry.children && Array.isArray(entry.children)) {
            processEntries(entry.children.reduce((acc, child) => {
                acc[child.path] = child;
                return acc;
            }, {}), contentPaths);
        }
    });
}

// Function to create or update a content file
function createContentFile(contentPath, fileId = null) {
    // Normalize the content path for file naming
    const normalizedPath = contentPath === '/' ? 'root' : contentPath;

    // Determine the content to use
    const contentTemplate = realContentTemplates[contentPath] ||
        realContentTemplates[normalizedPath] ||
        createDefaultTemplate(contentPath);

    // Create the file in md-content directory
    // Handle nested directory paths
    const fullPath = path.join(CONTENT_DIR, `${normalizedPath}.json`);
    const dirPath = path.dirname(fullPath);

    if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath, { recursive: true });
    }

    fs.writeFileSync(fullPath, JSON.stringify(contentTemplate, null, 2));
    console.log(`Created/updated content file: ${fullPath}`);

    // Create a direct access version if fileId is provided
    if (fileId) {
        // Handle nested directory paths for direct access files
        let directAccessPath;
        if (contentPath.includes('/')) {
            const parts = contentPath.split('/');
            const lastPart = parts.pop();
            const dirPart = parts.join('/');

            const targetDir = path.join(DIST_DIR, `md-content${dirPart}`);
            if (!fs.existsSync(targetDir)) {
                fs.mkdirSync(targetDir, { recursive: true });
            }

            directAccessPath = path.join(targetDir, `${fileId}.json`);
        } else {
            directAccessPath = path.join(DIST_DIR, `md-content${contentPath}${fileId}.json`);
        }

        fs.copyFileSync(fullPath, directAccessPath);
        console.log(`Created direct access file: ${directAccessPath}`);

        // Update mapping
        mapping[`md-content${contentPath}${fileId}`] = `md-content/${normalizedPath}.json`;
        console.log(`Added mapping: md-content${contentPath}${fileId} -> md-content/${normalizedPath}.json`);

        // Also create a simplified direct access version
        const noIdPath = path.join(DIST_DIR, `md-content${contentPath}.json`);
        fs.copyFileSync(fullPath, noIdPath);
        console.log(`Created simplified direct access file: ${noIdPath}`);

        mapping[`md-content${contentPath}`] = `md-content/${normalizedPath}.json`;
        console.log(`Added mapping: md-content${contentPath} -> md-content/${normalizedPath}.json`);
    }
}

// Function to create a default template for content without a template
function createDefaultTemplate(contentPath) {
    // Generate a more descriptive title by formatting the path
    const pathParts = contentPath.split('/').filter(Boolean);
    let title = pathParts.length > 0 ?
        pathParts[pathParts.length - 1]
            .split('-')
            .map(word => word.charAt(0).toUpperCase() + word.slice(1))
            .join(' ') :
        'Generated Content';

    // Create a rich content based on the path
    return {
        id: contentPath,
        title: title,
        contents: `<h1>${title}</h1>\n<p>This is the ${title} page for NForm.</p>\n<div pbl-example-view=\"pbl-${contentPath.replace(/\//g, '-')}-example\" exampleStyle=\"flow\"></div>`
    };
}
