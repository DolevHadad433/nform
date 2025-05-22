#!/bin/bash
# Complete solution for fixing webpack content structure issues in nform

echo "===== Starting comprehensive webpack content structure fix ====="

# 1. Create the webpack plugin for fixing content structure
cat > tools/fix-content-structure-plugin.js << 'EOL'
/**
 * Webpack plugin to fix content structure in pages.json
 * This plugin intercepts the markdown pages webpack plugin output 
 * and ensures the correct structure is generated
 */
const webpack = require('webpack');
const path = require('path');
const fs = require('fs');

class FixContentStructurePlugin {
  constructor(options = {}) {
    // Default options
    this.options = Object.assign(
      {
        pagesJsonPath: 'md-content/pages.json',
        generateContentFiles: true,
      },
      options
    );
  }

  apply(compiler) {
    // Hook into the emit phase
    compiler.hooks.emit.tapAsync('FixContentStructurePlugin', (compilation, callback) => {
      // Find the pages.json asset
      const pagesJsonAsset = compilation.assets[this.options.pagesJsonPath];
      
      if (pagesJsonAsset) {
        console.log('Found pages.json asset, fixing content structure...');
        
        try {
          // Get the current pages.json content
          const pagesJsonContent = pagesJsonAsset.source();
          const pagesJson = JSON.parse(pagesJsonContent);
          
          // Fix the structure
          const fixedPagesJson = this.fixContentStructure(pagesJson);
          
          // Replace the asset with the fixed version
          compilation.assets[this.options.pagesJsonPath] = {
            source: () => JSON.stringify(fixedPagesJson, null, 2),
            size: () => JSON.stringify(fixedPagesJson, null, 2).length
          };
          
          console.log('Successfully fixed pages.json structure');
          
          // Generate content files if needed
          if (this.options.generateContentFiles) {
            this.generateContentFiles(fixedPagesJson, compilation);
          }
        } catch (error) {
          console.error('Error fixing pages.json content structure:', error);
        }
      } else {
        console.warn('Could not find pages.json asset at', this.options.pagesJsonPath);
      }
      
      callback();
    });
  }
  
  fixContentStructure(pagesJson) {
    // Ensure we have the correct structure
    const fixedPagesJson = {
      entries: {},
      entryData: {}
    };
    
    // Fix the entries structure
    if (pagesJson.entries) {
      // Home page should have path "/"
      if (pagesJson.entries.home) {
        fixedPagesJson.entries["/"] = {
          ...pagesJson.entries.home,
          title: "Home",
          path: "/",
          type: "index"
        };
      } else {
        fixedPagesJson.entries["/"] = {
          title: "Home",
          path: "/",
          type: "index"
        };
      }
      
      // Fix the guide section to use the correct structure
      if (pagesJson.entries.guide) {
        fixedPagesJson.entries.guide = {
          ...pagesJson.entries.guide,
          title: "Guide",
          path: "guide",
          type: "topMenuSection",
          tooltip: "How-to Guide",
          searchGroup: "guide"
        };
        
        // Ensure children have the correct structure
        if (pagesJson.entries.guide.children) {
          fixedPagesJson.entries.guide.children = this.fixChildren(pagesJson.entries.guide.children);
        }
      }
      
      // Copy any other top-level entries
      Object.keys(pagesJson.entries).forEach(key => {
        if (key !== 'home' && key !== 'guide' && key !== '/') {
          fixedPagesJson.entries[key] = {
            ...pagesJson.entries[key],
            type: pagesJson.entries[key].type || "topMenuSection",
            tooltip: pagesJson.entries[key].tooltip || pagesJson.entries[key].title,
            searchGroup: pagesJson.entries[key].searchGroup || key
          };
          
          // Fix children for this section
          if (pagesJson.entries[key].children) {
            fixedPagesJson.entries[key].children = this.fixChildren(pagesJson.entries[key].children);
          }
        }
      });
    }
    
    // Fix the entryData structure - ensure all paths are correct
    if (pagesJson.entryData) {
      Object.keys(pagesJson.entryData).forEach(key => {
        const path = pagesJson.entryData[key];
        
        // Ensure path uses correct format
        let fixedPath = path;
        
        // If the path doesn't include a file extension, add .json
        if (!fixedPath.endsWith('.json')) {
          fixedPath = `${fixedPath}.json`;
        }
        
        // Ensure path uses the correct format for md-content
        if (!fixedPath.startsWith('md-content/')) {
          fixedPath = `md-content/${fixedPath}`;
        }
        
        fixedPagesJson.entryData[key] = fixedPath;
      });
    }
    
    return fixedPagesJson;
  }
  
  fixChildren(children) {
    if (!Array.isArray(children)) {
      return children;
    }
    
    return children.map(child => {
      const fixedChild = {
        ...child,
        tooltip: child.tooltip || child.title
      };
      
      if (child.children) {
        fixedChild.children = this.fixChildren(child.children);
      }
      
      return fixedChild;
    });
  }
  
  generateContentFiles(pagesJson, compilation) {
    console.log('Generating content files for entryData...');
    
    // Process each file in entryData
    Object.entries(pagesJson.entryData).forEach(([id, filePath]) => {
      // Skip if file already exists in compilation
      if (compilation.assets[filePath]) {
        console.log(`Content file already exists in compilation: ${filePath}`);
        return;
      }
      
      // Create content file
      const title = this.getPageTitle(id, pagesJson);
      const content = this.createContentTemplate(id, title);
      
      // Add to compilation assets
      compilation.assets[filePath] = {
        source: () => content,
        size: () => content.length
      };
      
      console.log(`Generated content file: ${filePath}`);
    });
  }
  
  getPageTitle(id, pagesJson) {
    // Find the page entry that matches this ID
    const searchForTitle = (entries) => {
      if (!entries) return null;
      
      for (const key in entries) {
        const entry = entries[key];
        
        // Check if this is the page we're looking for
        if (entry.path && entry.path.replace(/\//g, '-') === id) {
          return entry.title;
        }
        
        // Check children recursively
        if (entry.children) {
          const childTitle = this.searchTitleInChildren(entry.children, id);
          if (childTitle) return childTitle;
        }
      }
      
      return null;
    };
    
    const title = searchForTitle(pagesJson.entries) || `Content for ${id}`;
    return title;
  }
  
  searchTitleInChildren(children, id) {
    if (!Array.isArray(children)) return null;
    
    for (const child of children) {
      // Check if this child is the page we're looking for
      if (child.path && child.path.replace(/\//g, '-') === id) {
        return child.title;
      }
      
      // Check this child's children
      if (child.children) {
        const foundTitle = this.searchTitleInChildren(child.children, id);
        if (foundTitle) return foundTitle;
      }
    }
    
    return null;
  }
  
  createContentTemplate(id, title) {
    return JSON.stringify({
      id,
      title,
      contents: `# ${title}\n\nThis is content for ${id}.`
    }, null, 2);
  }
}

module.exports = FixContentStructurePlugin;
EOL

echo "✅ Created FixContentStructurePlugin in tools/fix-content-structure-plugin.js"

# 2. Create webpack config wrapper
cat > apps/nform-demo-app/build/webpack.content.js << 'EOL'
/**
 * Custom webpack configuration for content structure
 */
const path = require('path');
const FixContentStructurePlugin = require('../../../tools/fix-content-structure-plugin');

module.exports = (config, options) => {
  console.log('Applying content structure fix to webpack config...');
  
  // Add our plugin to the webpack config
  if (!config.plugins) {
    config.plugins = [];
  }
  
  // Add the content structure fix plugin
  config.plugins.push(new FixContentStructurePlugin({
    pagesJsonPath: 'md-content/pages.json',
    generateContentFiles: true
  }));
  
  console.log('Content structure fix plugin added to webpack config');
  
  return config;
};
EOL

echo "✅ Created webpack config wrapper in apps/nform-demo-app/build/webpack.content.js"

# 3. Create a comprehensive script to generate all content files that should exist
cat > generate-content-files-improved.js << 'EOL'
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
EOL

echo "✅ Created improved content file generator in generate-content-files-improved.js"

# 4. Create a script to update webpack config in project.json
cat > update-project-webpack-config.js << 'EOL'
/**
 * Script to update project.json to use the custom webpack config
 */
const fs = require('fs');
const path = require('path');

const projectJsonPath = path.resolve(__dirname, 'apps/nform-demo-app/project.json');

try {
  // Read the current project.json
  const projectJson = JSON.parse(fs.readFileSync(projectJsonPath, 'utf8'));
  
  // Update the build target to use the custom webpack config
  if (projectJson.targets && projectJson.targets.build && projectJson.targets.build.options) {
    projectJson.targets.build.options.webpackConfig = "apps/nform-demo-app/build/webpack.content.js";
    console.log('Updated project.json to use the custom webpack config');
  } else {
    console.error('Could not find the build target in project.json');
  }
  
  // Write the updated project.json
  fs.writeFileSync(projectJsonPath, JSON.stringify(projectJson, null, 2));
  console.log('Successfully updated project.json');
} catch (error) {
  console.error('Error updating project.json:', error.message);
}
EOL

echo "✅ Created script to update webpack config in project.json"

# 5. Create a script to run the complete fix
cat > build-with-fixed-content.sh << 'EOL'
#!/bin/bash
# Build the demo app with fixed content structure

echo "===== Building nform-demo-app with fixed content structure ====="

# Update project.json with the custom webpack config
echo "Updating project.json to use custom webpack config..."
node update-project-webpack-config.js

# Run the build with the custom webpack config
echo "Running build with content structure fixes..."
npx nx build nform-demo-app

# Verify the content files were created correctly
echo "Verifying content files..."
if [ -f "dist/md-content/pages.json" ]; then
  echo "✅ pages.json exists"
  
  # Run the improved content files generator to ensure all files exist
  echo "Running content files generator to ensure all files exist..."
  node generate-content-files-improved.js
  
  # Count the entryData entries and the corresponding files
  ENTRY_COUNT=$(grep -o '"md-content/' dist/md-content/pages.json | wc -l)
  FILE_COUNT=$(find dist/md-content -name "*.json" | grep -v "pages.json" | wc -l)
  
  echo "Found $ENTRY_COUNT entries in entryData"
  echo "Found $FILE_COUNT content files"
  
  if [ "$FILE_COUNT" -lt "$ENTRY_COUNT" ]; then
    echo "⚠️ Some content files are missing. Running generation script again..."
    node generate-content-files-improved.js
  else
    echo "✅ All content files exist"
  fi
  
  # Update the content server to use the correct port
  echo "Updating content server configuration..."
  sed -i '' 's/port = 4201/port = 4202/g' content-server.js 2>/dev/null || sed -i 's/port = 4201/port = 4202/g' content-server.js
  
  # Start the content server
  echo "Starting content server on port 4202..."
  nohup node content-server.js > content-server.log 2>&1 &
  echo "Content server started in background. Check content-server.log for details."
  echo "Content server available at: http://localhost:4202"
else
  echo "❌ pages.json not found. Build may have failed."
  exit 1
fi

echo "===== Content structure fix implementation complete! ====="
echo "You can now serve the app with: npm run start"
echo "The content will be served from the content server at http://localhost:4202"
echo "Make sure ContentMapService is configured to use port 4202"
EOL

chmod +x build-with-fixed-content.sh

echo "✅ Created build script at build-with-fixed-content.sh"

# 6. Create a guide document explaining the fix
cat > docs/WEBPACK_CONTENT_STRUCTURE_FIX.md << 'EOL'
# Webpack Content Structure Fix for nForm Demo App

This document explains the comprehensive fix for the webpack content structure issues in the nForm demo app.

## The Problem

The webpack build process was not creating the correct content structure in `pages.json` for the nForm demo app. The issues included:

1. Incorrect path formats in the `entryData` object
2. Missing navigation structure properties
3. Invalid JSON file references
4. Content files not being generated correctly

## The Solution

The solution includes several components:

### 1. Custom Webpack Plugin

A custom webpack plugin (`FixContentStructurePlugin`) was created to:
- Intercept the output of the markdown pages webpack plugin
- Fix the structure of `pages.json`
- Generate missing content files

### 2. Custom Webpack Config

A custom webpack configuration wrapper was created to apply the plugin during the build process.

### 3. Content File Generator

An improved content file generator script was created to ensure all referenced files exist.

### 4. Content Server

A standalone content server was implemented to serve JSON files on port 4202.

### 5. ContentMapService Updates

The `ContentMapService` was updated to:
- Use port 4202 for the content server
- Transform paths for correct content loading

## How to Use

1. Run the build with fixed content structure:
   ```
   ./build-with-fixed-content.sh
   ```

2. This will:
   - Update the webpack configuration
   - Build the app with the fixed content structure
   - Generate all necessary content files
   - Start the content server

3. Start the application:
   ```
   npm run start
   ```

## Technical Details

### Content Structure Format

The correct structure for `pages.json` is:

```json
{
  "entries": {
    "/": {
      "title": "Home",
      "path": "/",
      "type": "index"
    },
    "guide": {
      "title": "Guide",
      "path": "guide",
      "type": "topMenuSection",
      "tooltip": "How-to Guide",
      "searchGroup": "guide",
      "children": [...]
    }
  },
  "entryData": {
    "guide-introduction": "md-content/guide-introduction.json",
    "guide-basics-nform-basics": "md-content/guide-basics-nform-basics.json"
  }
}
```

### Content Server

The content server runs on port 4202 and serves files from the `dist` directory.

### Path Transformation

The `ContentMapService` transforms paths to use the content server for special paths:

```typescript
public transformPath(path: string): string {
  if (this.isDevEnvironment && path) {
    if (path.startsWith('md-content') && path.includes('/')) {
      return `${this.contentServerUrl}/${path}`;
    }
  }
  return path;
}
```

## Troubleshooting

If you encounter issues with the content not loading:

1. Check that the content server is running on port 4202
2. Verify that ContentMapService is using port 4202
3. Check the browser console for 404 errors
4. Run the content file generator again:
   ```
   node generate-content-files-improved.js
   ```

## Future Improvements

For a more permanent solution:

1. Modify the webpack markdown pages plugin to generate the correct structure directly
2. Integrate the content file generation into the build process
3. Add validation to ensure all referenced files exist
EOL

echo "✅ Created documentation for the fix in docs/WEBPACK_CONTENT_STRUCTURE_FIX.md"

echo "===== Webpack content structure fix setup complete! ====="
echo "To implement the fix, run: ./build-with-fixed-content.sh"
echo "This will build the app with the fixed content structure and start the content server."
echo "For more information, see docs/WEBPACK_CONTENT_STRUCTURE_FIX.md"
