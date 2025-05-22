/**
 * This script fixes content mapping issues, especially for files with paths like md-content5e8f84b66fd66837.json
 */
const fs = require('fs');
const path = require('path');

// Configuration
const DIST_DIR = path.join(__dirname, 'dist');
const CONTENT_DIR = path.join(DIST_DIR, 'md-content');
const MAPPING_FILE_PATH = path.join(DIST_DIR, 'nform-content-mapping.json');

// Ensure directories exist
if (!fs.existsSync(DIST_DIR)) {
    fs.mkdirSync(DIST_DIR, { recursive: true });
}

if (!fs.existsSync(CONTENT_DIR)) {
    fs.mkdirSync(CONTENT_DIR, { recursive: true });
}

// Function to scan a directory for content files
function scanDirectory(dir) {
    const results = [];
    const entries = fs.readdirSync(dir, { withFileTypes: true });

    for (const entry of entries) {
        const fullPath = path.join(dir, entry.name);

        if (entry.isDirectory()) {
            results.push(...scanDirectory(fullPath));
        } else if (entry.isFile() && entry.name.endsWith('.json')) {
            results.push(fullPath);
        }
    }

    return results;
}

// Add special content mapping for paths without slashes
function addSpecialContentMappings() {
    let mapping = {};

    // Load existing mapping if it exists
    if (fs.existsSync(MAPPING_FILE_PATH)) {
        try {
            mapping = JSON.parse(fs.readFileSync(MAPPING_FILE_PATH, 'utf8'));
            console.log('Loaded existing content mapping');
        } catch (error) {
            console.error('Error parsing existing mapping file:', error.message);
            console.log('Creating new mapping file');
        }
    }

    // Add standard mappings if they don't exist
    if (!mapping.markdownPages) {
        mapping.markdownPages = 'md-content/pages.json';
    }

    if (!mapping.markdownCodeExamples) {
        mapping.markdownCodeExamples = 'md-content/code-examples.json';
    }

    if (!mapping.searchContent) {
        mapping.searchContent = 'md-content/search-content.json';
    }

    // Check for existing content files
    const contentFiles = scanDirectory(CONTENT_DIR);
    console.log(`Found ${contentFiles.length} content files`);

    // Add special mappings for each content file
    contentFiles.forEach(filePath => {
        const fileName = path.basename(filePath);
        const fileId = fileName.replace('.json', '');

        // Create special format keys like md-content5e8f84b66fd66837.json
        const specialKey = `md-content${fileId}`;
        const relativePath = path.relative(DIST_DIR, filePath).replace(/\\/g, '/');

        mapping[specialKey] = relativePath;
        console.log(`Added mapping: ${specialKey} -> ${relativePath}`);

        // Create a symlink for direct access if it doesn't exist
        const symlinkPath = path.join(DIST_DIR, `${specialKey}.json`);
        if (!fs.existsSync(symlinkPath)) {
            try {
                // On Windows, we need to use a file copy instead of a symlink
                if (process.platform === 'win32') {
                    fs.copyFileSync(filePath, symlinkPath);
                    console.log(`Created file copy at ${symlinkPath}`);
                } else {
                    // Create relative symlink
                    const targetRelative = path.relative(path.dirname(symlinkPath), filePath);
                    fs.symlinkSync(targetRelative, symlinkPath);
                    console.log(`Created symlink at ${symlinkPath}`);
                }
            } catch (error) {
                console.error(`Error creating symlink/copy for ${specialKey}:`, error.message);

                // Try direct copy as fallback
                try {
                    fs.copyFileSync(filePath, symlinkPath);
                    console.log(`Created file copy (fallback) at ${symlinkPath}`);
                } catch (copyError) {
                    console.error(`Fallback copy also failed:`, copyError.message);
                }
            }
        }
    });

    // Create a specific file for your problematic path if it doesn't exist
    const specificFileId = '5e8f84b66fd66837';
    const specificFilePath = path.join(CONTENT_DIR, `${specificFileId}.json`);
    const specificKey = `md-content${specificFileId}`;

    if (!mapping[specificKey]) {
        if (!fs.existsSync(specificFilePath)) {
            // Create the specific file
            const specificContent = {
                title: "Generated Content",
                html: "<h1>This content was generated to fix 404 errors</h1><p>This file was missing from the content structure.</p>"
            };

            fs.writeFileSync(specificFilePath, JSON.stringify(specificContent, null, 2));
            console.log(`Created specific file at ${specificFilePath}`);
        }

        // Add to mapping
        mapping[specificKey] = `md-content/${specificFileId}.json`;
        console.log(`Added specific mapping: ${specificKey} -> md-content/${specificFileId}.json`);

        // Create a direct file for access
        const directFilePath = path.join(DIST_DIR, `${specificKey}.json`);
        fs.copyFileSync(specificFilePath, directFilePath);
        console.log(`Created direct file at ${directFilePath}`);
    }

    // Save the updated mapping
    fs.writeFileSync(MAPPING_FILE_PATH, JSON.stringify(mapping, null, 2));
    console.log(`Updated mapping file saved to ${MAPPING_FILE_PATH}`);
}

// Main execution
console.log('Starting comprehensive content fix...');
addSpecialContentMappings();
console.log('Content fix completed');
