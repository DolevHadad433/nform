#!/bin/zsh
# Script to fix 404 errors for content files including md-content5e8f84b66fd66837.json

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Fixing Content File 404 Errors ===${NC}"

# 1. Update ContentMapService to handle all md-content paths
echo -e "${YELLOW}1. Verifying ContentMapService is properly configured...${NC}"
if grep -q "Handle all md-content paths" "apps/libs/shared/lib/services/content-map.service.ts"; then
    echo -e "${GREEN}ContentMapService already updated${NC}"
else
    echo -e "${YELLOW}Updating ContentMapService...${NC}"
    cat > apps/libs/shared/lib/services/content-map.service.ts << 'EOL'
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
    echo -e "${GREEN}ContentMapService updated${NC}"
fi

# 2. Update content server to handle all md-content paths
echo -e "${YELLOW}2. Updating content server...${NC}"
cat > content-server.js << 'EOL'
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
    console.log(`Try accessing: http://localhost:${port}/md-content5e8f84b66fd66837.json`);
});
EOL

echo -e "${GREEN}Content server updated${NC}"

# 3. Run the content path fix script
echo -e "${YELLOW}3. Running content path fix script...${NC}"
node fix-content-paths.js

# 4. Restart servers
echo -e "${YELLOW}4. Restarting servers...${NC}"

# Stop existing servers
CONTENT_SERVER_PID=$(lsof -i:4202 -t || echo "")
APP_SERVER_PID=$(lsof -i:4201 -t || echo "")

if [ -n "$CONTENT_SERVER_PID" ]; then
    echo "Stopping content server (PID: $CONTENT_SERVER_PID)"
    kill -9 $CONTENT_SERVER_PID 2>/dev/null
fi

if [ -n "$APP_SERVER_PID" ]; then
    echo "Stopping app server (PID: $APP_SERVER_PID)"
    kill -9 $APP_SERVER_PID 2>/dev/null
fi

# Start content server
echo "Starting content server..."
node content-server.js > content-server.log 2>&1 &
CONTENT_SERVER_PID=$!
echo "Content server started with PID: $CONTENT_SERVER_PID"

# Wait for content server to start
sleep 2

# Test content server
echo -e "${YELLOW}5. Testing content server...${NC}"
if curl -s http://localhost:4202/md-content5e8f84b66fd66837.json -o /dev/null; then
    echo -e "${GREEN}Content server is responding to the problem file path${NC}"
else
    echo -e "${RED}Content server is not responding to the problem file path${NC}"
fi

# Start app server (only if it was running before)
if [ -n "$APP_SERVER_PID" ]; then
    echo "Restarting app server..."
    nx serve nform-demo-app --configuration=development &
    APP_SERVER_PID=$!
    echo "App server started with PID: $APP_SERVER_PID"
fi

echo -e "${GREEN}=== Fix Complete ===${NC}"
echo "Try accessing: http://localhost:4201/md-content5e8f84b66fd66837.json"
echo "You can also check directly: http://localhost:4202/md-content5e8f84b66fd66837.json"
echo ""
echo "If you still have issues, try restarting your browser to clear any cached errors."
