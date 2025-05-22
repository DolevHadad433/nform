/**
 * Improved script to create all content files referenced in pages.json
 * This version handles nested paths and ensures proper directory structure
 */
const fs = require('fs');
const path = require('path');
const mkdirp = require('mkdirp');

// Read the current pages.json
const pagesJsonPath = path.resolve(__dirname, 'dist/md-content/pages.json');

if (!fs.existsSync(pagesJsonPath)) {
  console.error(`Error: Cannot find pages.json at ${pagesJsonPath}`);
  console.log('Make sure to build the project first or create pages.json');
  process.exit(1);
}

const pages = JSON.parse(fs.readFileSync(pagesJsonPath, 'utf8'));

// Extract all referenced files from entryData
const entryData = pages.entryData || {};

// Create a sample content template
const createContentTemplate = (id, title) => {
  return JSON.stringify({
    id,
    title,
    contents: `# ${title}\n\nThis is content for ${id}.`
  }, null, 2);
};

console.log('Generating content files referenced in pages.json...');
console.log(`Found ${Object.keys(entryData).length} entries in entryData`);

// Helper function to get page title from the pages structure
function getPageTitle(id, pages) {
  // Try to find the page entry with a matching path
  const findEntryWithPath = (entries, targetId) => {
    if (!entries) return null;
    
    // Check each entry
    for (const key in entries) {
      const entry = entries[key];
      
      // Check if this entry's path matches the ID
      if (entry.path && entry.path.replace(/\//g, '-') === targetId) {
        return entry.title;
      }
      
      // Check children recursively
      if (entry.children && Array.isArray(entry.children)) {
        for (let i = 0; i < entry.children.length; i++) {
          const child = entry.children[i];
          
          // Check if this child's path matches the ID
          if (child.path && child.path.replace(/\//g, '-') === targetId) {
            return child.title;
          }
          
          // Check nested children
          if (child.children && Array.isArray(child.children)) {
            const nestedTitle = findEntryWithPath({ nested: { children: child.children } }, targetId);
            if (nestedTitle) return nestedTitle;
          }
        }
      }
    }
    
    return null;
  };
  
  // Try to find a title, fallback to the ID if not found
  return findEntryWithPath(pages.entries, id) || `Content for ${id}`;
}

// Process each file in entryData
Object.entries(entryData).forEach(([id, filePath]) => {
  const fullPath = path.resolve(__dirname, 'dist', filePath);
  const dirPath = path.dirname(fullPath);
  
  // Create directory if it doesn't exist
  if (!fs.existsSync(dirPath)) {
    console.log(`Creating directory: ${dirPath}`);
    mkdirp.sync(dirPath);
  }
  
  // Check if file exists, if not create it
  if (!fs.existsSync(fullPath)) {
    const title = getPageTitle(id, pages);
    const content = createContentTemplate(id, title);
    
    console.log(`Creating file: ${fullPath}`);
    fs.writeFileSync(fullPath, content);
  } else {
    console.log(`File already exists: ${fullPath}`);
  }
});

console.log('Content generation complete!');
