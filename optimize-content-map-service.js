/**
 * Script to optimize ContentMapService for handling all content path formats
 */
const fs = require('fs');
const path = require('path');

// Configuration
const CONTENT_MAP_SERVICE_PATH = path.join(__dirname, 'apps', 'libs', 'shared', 'lib', 'services', 'content-map.service.ts');

// Check if file exists
if (!fs.existsSync(CONTENT_MAP_SERVICE_PATH)) {
  console.error(`ContentMapService not found at: ${CONTENT_MAP_SERVICE_PATH}`);
  process.exit(1);
}

// Read ContentMapService
let contentMapService = fs.readFileSync(CONTENT_MAP_SERVICE_PATH, 'utf8');

// Add CONTENT_SERVER_URL webpack constant declaration if missing
if (!contentMapService.includes('declare const CONTENT_SERVER_URL:')) {
  console.log('Adding CONTENT_SERVER_URL constant declaration...');

  // Add the declaration after NFORM_CONTENT_MAPPING_FILE declaration
  contentMapService = contentMapService.replace(
    'declare const NFORM_CONTENT_MAPPING_FILE: string;',
    'declare const NFORM_CONTENT_MAPPING_FILE: string;\n\n// Using fallback value if webpack doesn\'t define the content server URL\ndeclare const CONTENT_SERVER_URL: string;'
  );
}

// Update contentServerUrl to use webpack-provided value with fallback
if (!contentMapService.includes('typeof CONTENT_SERVER_URL !==')) {
  console.log('Updating contentServerUrl to use webpack constant...');

  // Replace the hardcoded URL with a fallback mechanism
  contentMapService = contentMapService.replace(
    /private contentServerUrl = this\.isDevEnvironment \? ['"]http:\/\/localhost:4202['"] : ['']?['']?;/,
    'private contentServerUrl = typeof CONTENT_SERVER_URL !== \'undefined\' ? CONTENT_SERVER_URL : (this.isDevEnvironment ? \'http://localhost:4202\' : \'\');'
  );
}

// Enhanced transformPath method with better logging and error handling
const enhancedTransformPath = `public transformPath(path: string): string {
    if (!path) {
      if (this.debugMode) console.log(\`\${this.logPrefix} Skipping null or empty path\`);
      return path;
    }
    
    if (this.isDevEnvironment) {
      // Handle all md-content paths, whether they have slashes or not
      if (path.startsWith('md-content')) {
        // Remove any duplicate slashes
        const normalizedPath = path.replace(/\\/\\//g, '/');
        
        // Transform the path to use content server
        const transformedPath = \`\${this.contentServerUrl}/\${normalizedPath}\`;
        
        if (this.debugMode) {
          console.log(\`\${this.logPrefix} Transforming path: "\${path}" to "\${transformedPath}"\`);
          
          // Log diagnostic info for debugging
          if (path.includes('/')) {
            console.log(\`\${this.logPrefix} Path contains slashes - format: "md-content/file.json"\`);
          } else if (path.match(/md-content[a-z0-9-]+[a-f0-9]{16}\.json/i)) {
            console.log(\`\${this.logPrefix} Path contains ID - format: "md-contentfileID.json"\`);
          } else {
            console.log(\`\${this.logPrefix} Path is simple - format: "md-contentfile.json"\`);
          }
        }
        
        return transformedPath;
      }
    }
    
    if (this.debugMode) {
      console.log(\`\${this.logPrefix} Using path as is: "\${path}"\`);
    }
    return path;
  }`;

// Replace the existing transformPath method with our enhanced version
console.log('Enhancing transformPath method with improved handling...');

// Find and replace the transformPath method
const transformPathRegex = /public\s+transformPath\s*\(\s*path\s*:\s*string\s*\)\s*:\s*string\s*{[\s\S]*?return\s+path;\s*}/;
contentMapService = contentMapService.replace(transformPathRegex, enhancedTransformPath);

// Update the file
fs.writeFileSync(CONTENT_MAP_SERVICE_PATH, contentMapService, 'utf8');
console.log('ContentMapService has been optimized successfully!');
console.log(`Updated file: ${CONTENT_MAP_SERVICE_PATH}`);

// Final verification
const updatedContent = fs.readFileSync(CONTENT_MAP_SERVICE_PATH, 'utf8');
if (updatedContent.includes('typeof CONTENT_SERVER_URL !==') &&
  updatedContent.includes('md-content[a-z0-9-]+[a-f0-9]{16}\\.json')) {
  console.log('Verification successful: All optimizations applied correctly');
} else {
  console.warn('Verification warning: Some optimizations may not have been applied correctly');
}

console.log('Done!');

if (this.debugMode) {
  console.log(\`\${this.logPrefix} Using path as is: "\${path}"\`);
    }
    return path;
  }`;

  // Replace the existing transformPath method
  const updatedContent = contentMapService.replace(
    /public transformPath\(path: string\): string {[\s\S]*?return path;\s*}/,
    enhancedTransformPath
  );

  // Write updated ContentMapService
  fs.writeFileSync(CONTENT_MAP_SERVICE_PATH, updatedContent);
  console.log('ContentMapService optimized successfully with enhanced path handling');
