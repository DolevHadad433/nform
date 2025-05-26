/**
 * Script to create a direct access file for the specific quick-start content file
 */
const fs = require('fs');
const path = require('path');

// Configuration
const DIST_DIR = path.join(__dirname, 'dist');
const CONTENT_DIR = path.join(DIST_DIR, 'md-content');
const SOURCE_FILE = path.join(CONTENT_DIR, 'quick-start.json');
const TARGET_FILE = path.join(DIST_DIR, 'md-contentquick-start262c9362fd2f6e2f.json');
const MAPPING_FILE_PATH = path.join(DIST_DIR, 'nform-content-mapping.json');

console.log('Creating direct access file for quick-start...');

// Check if source file exists
if (!fs.existsSync(SOURCE_FILE)) {
    console.error(`Source file does not exist: ${SOURCE_FILE}`);

    // Create source file with real content
    const sourceContent = {
        id: "quick-start",
        title: "Quick Start",
        contents: "<div pbl-app-content-chunk=\"pbl-quick-start-app-content-chunk\"></div>\n<h1>Quick Start Guide</h1>\n<p>This is the official quick start guide for nForm.</p>\n<br>\n<br>"
    };

    try {
        fs.mkdirSync(CONTENT_DIR, { recursive: true });
        fs.writeFileSync(SOURCE_FILE, JSON.stringify(sourceContent, null, 2));
        console.log(`Created source file at ${SOURCE_FILE}`);
    } catch (error) {
        console.error(`Failed to create source file: ${error.message}`);
        process.exit(1);
    }
}

// Create target file
try {
    fs.copyFileSync(SOURCE_FILE, TARGET_FILE);
    console.log(`Created direct access file at ${TARGET_FILE}`);
} catch (error) {
    console.error(`Failed to create target file: ${error.message}`);
    process.exit(1);
}

// Update mapping file
let mapping = {};
if (fs.existsSync(MAPPING_FILE_PATH)) {
    try {
        mapping = JSON.parse(fs.readFileSync(MAPPING_FILE_PATH, 'utf8'));
        console.log('Loaded existing content mapping');
    } catch (error) {
        console.error(`Error parsing mapping file: ${error.message}`);
    }
}

// Add this specific mapping
mapping['md-contentquick-start262c9362fd2f6e2f'] = 'md-content/quick-start.json';
console.log('Added mapping: md-contentquick-start262c9362fd2f6e2f -> md-content/quick-start.json');

// Save updated mapping
fs.writeFileSync(MAPPING_FILE_PATH, JSON.stringify(mapping, null, 2));
console.log(`Updated mapping file saved to ${MAPPING_FILE_PATH}`);

console.log('Quick-start direct access fix completed');
