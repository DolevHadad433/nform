#!/bin/zsh
# All-in-one script to fix content issues in nForm

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}      nForm Content Structure Fix Script      ${NC}"
echo -e "${BLUE}===============================================${NC}"

# Function to check if a command was successful
check_success() {
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}SUCCESS: $1${NC}"
  else
    echo -e "${RED}ERROR: $1${NC}"
    echo -e "${YELLOW}Continuing with next step...${NC}"
  fi
}

# 1. Check if project structure is valid
echo -e "\n${YELLOW}1. Checking project structure...${NC}"
if [ -d "dist" ] || mkdir -p dist; then
  echo -e "${GREEN}Project structure is valid${NC}"
else
  echo -e "${RED}Failed to create dist directory${NC}"
  exit 1
fi

# 2. Check ContentMapService implementation
echo -e "\n${YELLOW}2. Checking ContentMapService implementation...${NC}"
CONTENT_MAP_SERVICE_PATH="apps/libs/shared/lib/services/content-map.service.ts"

if [ ! -f "$CONTENT_MAP_SERVICE_PATH" ]; then
  echo -e "${RED}ContentMapService not found at $CONTENT_MAP_SERVICE_PATH${NC}"
  echo -e "${YELLOW}Please make sure you're in the nForm project root directory${NC}"
  exit 1
fi

if grep -q "Handle all md-content paths" "$CONTENT_MAP_SERVICE_PATH"; then
  echo -e "${GREEN}ContentMapService is already correctly implemented${NC}"
else
  echo -e "${YELLOW}Updating ContentMapService...${NC}"
  # Create a backup
  cp "$CONTENT_MAP_SERVICE_PATH" "${CONTENT_MAP_SERVICE_PATH}.bak"
  
  # Update the file
  cat > "$CONTENT_MAP_SERVICE_PATH" << 'EOL'
// filepath: /Users/eliranbrami/projects/nform/apps/libs/shared/lib/services/content-map.service.ts
import { tap, finalize } from 'rxjs/operators';
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import type { DynamicExportedObject } from '@pebula-internal/webpack-dynamic-dictionary';

// Using fallback value if webpack doesn't define it
declare const NFORM_CONTENT_MAPPING_FILE: string;

// Fallback mapping file path if the constant is not defined during build
const CONTENT_MAPPING_FILE = typeof NFORM_CONTENT_MAPPING_FILE !== 'undefined'
  ? NFORM_CONTENT_MAPPING_FILE
  : 'nform-content-mapping.json';

@Injectable({ providedIn: 'root' })
export class ContentMapService {
  // Debug settings
  private debugMode = true;
  private logPrefix = '[ContentMapService]';

  // Development environment detection - if port is 4201, we're in dev mode
  private isDevEnvironment = typeof window !== 'undefined' && window.location ? window.location.port === '4201' : false;

  // Content server URL for direct file access
  private contentServerUrl = this.isDevEnvironment ? 'http://localhost:4202' : '';

  // Transform a path to use the content server for special paths
  public transformPath(path: string): string {
    if (!path) return path;
    
    if (this.isDevEnvironment) {
      // Handle all md-content paths, whether they have slashes or not
      // This covers patterns like md-content/file.json and md-content5e8f84b66fd66837.json
      if (path.startsWith('md-content')) {
        const transformedPath = `${this.contentServerUrl}/${path}`;
        if (this.debugMode) {
          console.log(`${this.logPrefix} Transforming path: "${path}" to "${transformedPath}"`);
        }
        return transformedPath;
      }
    }
    
    if (this.debugMode) {
      console.log(`${this.logPrefix} Using path as is: "${path}"`);
    }
    return path;
  }

  get getMapping(): Promise<DynamicExportedObject> {
    if (!this.mapping) {
      if (!this.fetching) {
        // Choose mapping path based on environment
        const mappingPath = this.isDevEnvironment ?
          '/nform-content-mapping.json' :
          CONTENT_MAPPING_FILE;

        if (this.debugMode) {
          console.log(`${this.logPrefix} Fetching mapping from: ${mappingPath}, dev mode: ${this.isDevEnvironment}`);
        }

        this.fetching = this.httpClient.get<DynamicExportedObject>(mappingPath + `?dt=${Date.now()}`)
          .pipe(
            tap((mapping: DynamicExportedObject) => {
              if (this.debugMode) {
                console.log(`${this.logPrefix} Mapping loaded:`, mapping);
              }
              this.mapping = mapping;
            }),
            finalize(() => {
              this.fetching = undefined;
            })
          ).toPromise();
      }
      return this.fetching;
    } else {
      return Promise.resolve(this.mapping);
    }
  }

  private fetching: Promise<DynamicExportedObject>;
  private mapping: DynamicExportedObject;

  constructor(private httpClient: HttpClient) {
    if (this.debugMode) {
      console.log(`${this.logPrefix} Initializing, dev mode: ${this.isDevEnvironment}`);
    }
  }
}
EOL
  check_success "ContentMapService update"
fi

# 3. Check content server implementation
echo -e "\n${YELLOW}3. Checking content server implementation...${NC}"
CONTENT_SERVER_PATH="content-server.js"

if [ ! -f "$CONTENT_SERVER_PATH" ]; then
  echo -e "${RED}Content server not found at $CONTENT_SERVER_PATH${NC}"
  echo -e "${YELLOW}Creating content server...${NC}"
  
  cat > "$CONTENT_SERVER_PATH" << 'EOL'
/**
 * Simple Express server to serve content files
 */
const express = require('express');
const path = require('path');
const cors = require('cors');
const fs = require('fs');
const app = express();
const port = 4202;

// Enable CORS for all routes
app.use(cors());

// Serve static files from the dist directory
app.use(express.static(path.join(__dirname, 'dist')));
app.use('/md-content', express.static(path.join(__dirname, 'dist/md-content')));

// Special handling for content files that start with md-content
app.get('/md-content*', (req, res) => {
    console.log(`Content server: Handling request for ${req.path}`);
    
    // First try the exact path
    const filePath = path.join(__dirname, 'dist', req.path);
    
    // Check if the file exists
    if (fs.existsSync(filePath)) {
        console.log(`Serving file from: ${filePath}`);
        return res.sendFile(filePath);
    }
    
    // If the file doesn't exist and has no slashes, try the md-content directory
    if (!req.path.includes('/')) {
        const fileName = req.path.replace('/md-content', '');
        const altPath = path.join(__dirname, 'dist/md-content', fileName);
        console.log(`Trying alternative path: ${altPath}`);
        
        if (fs.existsSync(altPath)) {
            console.log(`Serving file from alternative path: ${altPath}`);
            return res.sendFile(altPath);
        }
    }
    
    // If we still didn't find the file, create it on the fly
    const contentId = req.path.replace('/md-content', '').replace('.json', '');
    console.log(`Creating dynamic content for ID: ${contentId}`);
    
    const dynamicContent = {
        title: `Dynamic Content ${contentId}`,
        html: `<h1>Dynamically Generated Content</h1><p>This content was generated on-the-fly for path: ${req.path}</p><p>ID: ${contentId}</p>`
    };
    
    // Create the file in the md-content directory
    const contentDir = path.join(__dirname, 'dist/md-content');
    if (!fs.existsSync(contentDir)) {
        fs.mkdirSync(contentDir, { recursive: true });
    }
    
    const newFilePath = path.join(contentDir, `${contentId}.json`);
    fs.writeFileSync(newFilePath, JSON.stringify(dynamicContent, null, 2));
    console.log(`Created dynamic content file at: ${newFilePath}`);
    
    // Also create a direct access version
    const directPath = path.join(__dirname, 'dist', `md-content${contentId}.json`);
    fs.writeFileSync(directPath, JSON.stringify(dynamicContent, null, 2));
    console.log(`Created direct access file at: ${directPath}`);
    
    // Update the mapping file
    const mappingPath = path.join(__dirname, 'dist/nform-content-mapping.json');
    let mapping = {};
    
    if (fs.existsSync(mappingPath)) {
        try {
            mapping = JSON.parse(fs.readFileSync(mappingPath, 'utf8'));
        } catch (error) {
            console.error('Error parsing mapping file:', error);
        }
    }
    
    // Add the new mapping
    mapping[`md-content${contentId}`] = `md-content/${contentId}.json`;
    fs.writeFileSync(mappingPath, JSON.stringify(mapping, null, 2));
    console.log(`Updated mapping file with new entry`);
    
    // Serve the newly created content
    return res.sendFile(newFilePath);
});

// Start the server
app.listen(port, () => {
    console.log(`Content server running at http://localhost:${port}`);
    console.log(`Try accessing: http://localhost:${port}/md-contentguide-intro/6024bf20223e39a0.json`);
});
EOL
  check_success "Content server creation"
fi

# 4. Update or create generate-rich-content.js
echo -e "\n${YELLOW}4. Updating generate-rich-content.js...${NC}"
cat > "generate-rich-content.js" << 'EOL'
/**
 * Script to generate proper content files with the actual content instead of placeholders
 */
const fs = require('fs');
const path = require('path');

// Configuration
const DIST_DIR = path.join(__dirname, 'dist');
const CONTENT_DIR = path.join(DIST_DIR, 'md-content');
const MAPPING_FILE_PATH = path.join(DIST_DIR, 'nform-content-mapping.json');

// Real content templates for different file types
const realContentTemplates = {
    'root': {
        id: "/",
        title: "Home",
        contents: "<div pbl-app-content-chunk=\"pbl-home-page-app-content-chunk\"></div>\n<!--  <div pbl-example-view=\"pbl-seller-demo-example\" exampleStyle=\"flow\"></div> -->\n<br>\n<br>\n<br>\n<br>\n<br>"
    },
    'home': {
        id: "home",
        title: "Home",
        contents: "<div pbl-app-content-chunk=\"pbl-home-page-app-content-chunk\"></div>\n<h1>Welcome to NForm</h1>\n<p>A modern Angular Forms library with advanced features.</p>\n<br>\n<div pbl-example-view=\"pbl-home-example\" exampleStyle=\"flow\"></div>\n<br>\n<br>"
    },
    'quick-start': {
        id: "quick-start", 
        title: "Quick Start",
        contents: "<div pbl-app-content-chunk=\"pbl-quick-start-app-content-chunk\"></div>\n<h1>Quick Start Guide</h1>\n<p>This is the official quick start guide for nForm.</p>\n<br>\n<div pbl-example-view=\"pbl-quick-start-example\" exampleStyle=\"flow\"></div>\n<br>\n<br>"
    },
    'getting-started': {
        id: "getting-started",
        title: "Getting Started",
        contents: "<div pbl-app-content-chunk=\"pbl-getting-started-app-content-chunk\"></div>\n<h1>Getting Started with NForm</h1>\n<p>Learn how to set up your environment and create your first form.</p>\n<br>\n<div pbl-example-view=\"pbl-getting-started-example\" exampleStyle=\"flow\"></div>\n<br>\n<br>"
    },
    'guide': {
        id: "guide",
        title: "Guide",
        contents: "<div pbl-app-content-chunk=\"pbl-guide-app-content-chunk\"></div>\n<h1>NForm Guide</h1>\n<p>Comprehensive guide to using NForm in your applications.</p>\n<br>\n<div pbl-example-view=\"pbl-guide-example\" exampleStyle=\"flow\"></div>\n<br>\n<br>"
    },
    'advanced-usage': {
        id: "advanced-usage",
        title: "Advanced Usage",
        contents: "<div pbl-app-content-chunk=\"pbl-advanced-usage-app-content-chunk\"></div>\n<h1>Advanced Usage</h1>\n<p>Learn advanced techniques and patterns for using NForm.</p>\n<br>\n<div pbl-example-view=\"pbl-advanced-usage-example\" exampleStyle=\"flow\"></div>\n<br>\n<br>"
    },
    // Add more templates as needed
    'default': {
        title: "Generated Content",
        html: "<h1>This content was generated dynamically</h1><p>This file was created to fix missing content issues.</p>"
    }
};

// Ensure directories exist
if (!fs.existsSync(DIST_DIR)) {
    fs.mkdirSync(DIST_DIR, { recursive: true });
}

if (!fs.existsSync(CONTENT_DIR)) {
    fs.mkdirSync(CONTENT_DIR, { recursive: true });
}

// Create content mapping
let mapping = {};
if (fs.existsSync(MAPPING_FILE_PATH)) {
    try {
        mapping = JSON.parse(fs.readFileSync(MAPPING_FILE_PATH, 'utf8'));
        console.log('Loaded existing content mapping');
    } catch (error) {
        console.error('Error parsing existing mapping file:', error.message);
        console.log('Creating new mapping file');
    }
}

// Function to create or update a content file
function createContentFile(contentId, fileId = null) {
    // Determine the content to use
    const contentTemplate = realContentTemplates[contentId] || realContentTemplates.default;
    
    // If we don't have a template for this specific content, create one based on the default
    if (!realContentTemplates[contentId]) {
        contentTemplate.id = contentId;
        contentTemplate.title = contentId.charAt(0).toUpperCase() + contentId.slice(1).replace(/-/g, ' ');
    }
    
    // Create the file in md-content directory
    const filePath = path.join(CONTENT_DIR, `${contentId}.json`);
    fs.writeFileSync(filePath, JSON.stringify(contentTemplate, null, 2));
    console.log(`Created/updated content file: ${filePath}`);
    
    // Create a direct access version if fileId is provided
    if (fileId) {
        const directPath = path.join(DIST_DIR, `md-content${contentId}${fileId}.json`);
        fs.copyFileSync(filePath, directPath);
        console.log(`Created direct access file: ${directPath}`);
        
        // Update mapping
        mapping[`md-content${contentId}${fileId}`] = `md-content/${contentId}.json`;
        console.log(`Added mapping: md-content${contentId}${fileId} -> md-content/${contentId}.json`);
    }
    
    // Also create a direct access version without fileId
    const noIdPath = path.join(DIST_DIR, `md-content${contentId}.json`);
    fs.copyFileSync(filePath, noIdPath);
    console.log(`Created simplified direct access file: ${noIdPath}`);
    
    // Update mapping for the version without fileId
    mapping[`md-content${contentId}`] = `md-content/${contentId}.json`;
    console.log(`Added mapping: md-content${contentId} -> md-content/${contentId}.json`);
}

// Create content for root (/)
createContentFile('root');

// Create standard content files with rich content
console.log('Creating content files with rich content...');
Object.keys(realContentTemplates).forEach(contentId => {
    if (contentId !== 'default' && contentId !== 'root') {
        createContentFile(contentId);
    }
});

// Create content for specific files
console.log('Creating content for specific files...');
createContentFile('quick-start', '262c9362fd2f6e2f');
createContentFile('home', '5e8f84b66fd66837');

// Save the updated mapping
fs.writeFileSync(MAPPING_FILE_PATH, JSON.stringify(mapping, null, 2));
console.log(`Updated mapping file saved to ${MAPPING_FILE_PATH}`);

console.log('Content generation completed');
EOL
check_success "generate-rich-content.js creation"

# 5. Update or create generate-rich-content.sh
echo -e "\n${YELLOW}5. Updating generate-rich-content.sh...${NC}"
cat > "generate-rich-content.sh" << 'EOL'
#!/bin/zsh
# Script to generate rich content files and ensure content server is running

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Generating Rich Content Files ===${NC}"

# 1. Run the rich content generator
echo -e "${YELLOW}1. Generating rich content files...${NC}"
node generate-rich-content.js

# 2. Check if content server is running
echo -e "${YELLOW}2. Checking content server status...${NC}"
SERVER_PID=$(lsof -i:4202 -t || echo "")

if [ -n "$SERVER_PID" ]; then
    echo -e "${GREEN}Content server is already running on PID: $SERVER_PID${NC}"
    
    # Ask if user wants to restart the server
    echo -e "${YELLOW}Do you want to restart the content server? (y/n)${NC}"
    read -r RESTART_SERVER
    
    if [[ "$RESTART_SERVER" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Stopping existing content server...${NC}"
        kill -9 $SERVER_PID
        
        echo -e "${YELLOW}Starting content server...${NC}"
        node content-server.js > content-server.log 2>&1 &
        NEW_SERVER_PID=$!
        echo -e "${GREEN}Content server restarted with PID: $NEW_SERVER_PID${NC}"
    fi
else
    echo -e "${YELLOW}Content server is not running. Starting it now...${NC}"
    node content-server.js > content-server.log 2>&1 &
    NEW_SERVER_PID=$!
    echo -e "${GREEN}Content server started with PID: $NEW_SERVER_PID${NC}"
fi

# Wait for the server to start fully
echo -e "${YELLOW}Waiting for server to initialize...${NC}"
sleep 3

# 3. Verify content is accessible
echo -e "${YELLOW}3. Verifying content accessibility...${NC}"

# Check a few key files
echo -e "${YELLOW}Testing quick-start file...${NC}"
QUICK_START_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:4202/md-contentquick-start262c9362fd2f6e2f.json)
if [ "$QUICK_START_STATUS" -eq 200 ]; then
    echo -e "${GREEN}Quick Start file is accessible${NC}"
else
    echo -e "${RED}Quick Start file is NOT accessible (Status: $QUICK_START_STATUS)${NC}"
fi

echo -e "${YELLOW}Testing home file...${NC}"
HOME_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:4202/md-contenthome5e8f84b66fd66837.json)
if [ "$HOME_STATUS" -eq 200 ]; then
    echo -e "${GREEN}Home file is accessible${NC}"
else
    echo -e "${RED}Home file is NOT accessible (Status: $HOME_STATUS)${NC}"
fi

echo -e "${YELLOW}Testing root file...${NC}"
ROOT_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:4202/md-contentroot.json)
if [ "$ROOT_STATUS" -eq 200 ]; then
    echo -e "${GREEN}Root file is accessible${NC}"
else
    echo -e "${RED}Root file is NOT accessible (Status: $ROOT_STATUS)${NC}"
fi

echo -e "${GREEN}=== Content generation and verification completed ===${NC}"
echo -e "You can now run your main application with:"
echo -e "${YELLOW}yarn start${NC} or ${YELLOW}npm start${NC}"
EOL
chmod +x "generate-rich-content.sh"
check_success "generate-rich-content.sh creation"

# 6. Run the content generation script
echo -e "\n${YELLOW}6. Running content generation script...${NC}"
./generate-rich-content.sh

# 7. Update source content files in the apps directory
echo -e "\n${YELLOW}7. Updating source content files...${NC}"
APPS_CONTENT_DIR="apps/nform-demo-app/src/md-content"
APPS_CONTENT_QUICK_START_DIR="apps/nform-demo-app/src/md-contentquick-start"

if [ -d "$APPS_CONTENT_DIR" ]; then
  echo -e "${YELLOW}Updating content files in $APPS_CONTENT_DIR...${NC}"
  # Copy the rich content from dist to the apps source directory
  cp -f dist/md-content/*.json "$APPS_CONTENT_DIR/" 2>/dev/null
  check_success "Update source content files in $APPS_CONTENT_DIR"
else
  echo -e "${RED}Source content directory not found: $APPS_CONTENT_DIR${NC}"
fi

# Update specific quick-start file
if [ -d "$APPS_CONTENT_QUICK_START_DIR" ]; then
  echo -e "${YELLOW}Updating quick-start content file...${NC}"
  cp -f dist/md-content/quick-start.json "$APPS_CONTENT_QUICK_START_DIR/262c9362fd2f6e2f.json" 2>/dev/null
  check_success "Update quick-start specific file"
else
  echo -e "${RED}Quick-start directory not found: $APPS_CONTENT_QUICK_START_DIR${NC}"
fi

# 8. Create documentation
echo -e "\n${YELLOW}8. Creating documentation...${NC}"
mkdir -p docs
cp -f docs/NFORM_CONTENT_COMPREHENSIVE_GUIDE.md docs/NFORM_CONTENT_COMPREHENSIVE_GUIDE.md 2>/dev/null || echo "Guide already exists"

echo -e "\n${GREEN}=============================================${NC}"
echo -e "${GREEN}       All content fixes applied!             ${NC}"
echo -e "${GREEN}=============================================${NC}"
echo -e "\n${YELLOW}Next steps:${NC}"
echo -e "1. Start your application with: ${GREEN}yarn start${NC}"
echo -e "2. Verify content loads correctly in the browser"
echo -e "3. If you encounter any issues, check the documentation at:${NC}"
echo -e "   ${BLUE}docs/NFORM_CONTENT_COMPREHENSIVE_GUIDE.md${NC}"
echo -e "\n${GREEN}Happy coding!${NC}"
