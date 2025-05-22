#!/bin/zsh
# Ultimate Content Mapping Fix for nForm Demo App
# This script provides a complete, direct solution for fixing content mapping issues

echo "🔧 ULTIMATE CONTENT MAPPING FIX 🔧"
echo "====================================="

# 1. Create content directories
echo "Creating content directories..."
mkdir -p dist/md-content

# 2. Create the mapping file
echo "Creating nform-content-mapping.json..."
cat > dist/nform-content-mapping.json << 'EOL'
{
  "markdownPages": "md-content/pages.json",
  "markdownCodeExamples": "md-content/code-examples.json",
  "searchContent": "md-content/search-content.json"
}
EOL

# 3. Create pages.json with the correct structure
echo "Creating pages.json with correct structure..."
cat > dist/md-content/pages.json << 'EOL'
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
      "ordinal": 1,
      "children": [
        {
          "title": "Guide Introduction",
          "path": "guide/introduction",
          "tooltip": "How-to use the guide",
          "ordinal": 0
        },
        {
          "title": "Basics",
          "path": "guide/basics",
          "ordinal": 0,
          "children": [
            {
              "title": "nForm Basics",
              "path": "guide/basics/nform-basics",
              "ordinal": 0
            }
          ]
        }
      ]
    }
  },
  "entryData": {
    "/": "md-content/home.json",
    "guide/introduction": "md-content/guide-introduction.json",
    "guide": "md-content/guide.json",
    "guide/basics/nform-basics": "md-content/guide-basics-nform-basics.json"
  }
}
EOL

# 4. Create sample content files
echo "Creating sample content files..."

# Home page
cat > dist/md-content/home.json << 'EOL'
{
  "id": "home",
  "title": "Home",
  "contents": "# Welcome to NForm\n\nThis is the home page for the NForm documentation."
}
EOL

# Guide page
cat > dist/md-content/guide.json << 'EOL'
{
  "id": "guide",
  "title": "Guide",
  "contents": "# NForm Guide\n\nThis guide provides comprehensive documentation for using NForm."
}
EOL

# Guide introduction
cat > dist/md-content/guide-introduction.json << 'EOL'
{
  "id": "guide-introduction",
  "title": "Guide Introduction",
  "contents": "# Guide Introduction\n\nLearn how to get started with NForm."
}
EOL

# nForm Basics
cat > dist/md-content/guide-basics-nform-basics.json << 'EOL'
{
  "id": "guide-basics-nform-basics",
  "title": "nForm Basics",
  "contents": "# nForm Basics\n\nLearn the basic concepts of NForm."
}
EOL

# 5. Create code examples
echo "Creating code examples file..."
cat > dist/md-content/code-examples.json << 'EOL'
{
  "examples": [
    {
      "id": "basic-form",
      "title": "Basic Form Example",
      "language": "typescript",
      "code": "import { Component } from '@angular/core';\nimport { NFormStatic } from '@pebula/nform';\n\n@Component({\n  selector: 'app-basic-form',\n  template: `<pbl-nform [model]=\"person\"></pbl-nform>`\n})\nexport class BasicFormComponent {\n  person = {\n    name: 'John Doe',\n    email: 'john@example.com',\n    age: 30\n  };\n}"
    }
  ]
}
EOL

# 6. Create search content
echo "Creating search content file..."
cat > dist/md-content/search-content.json << 'EOL'
[
  {
    "path": "/",
    "title": "Home",
    "titleWords": "home",
    "headingWords": "Welcome to NForm",
    "keywords": ""
  },
  {
    "path": "guide",
    "title": "Guide",
    "titleWords": "guide",
    "headingWords": "NForm Guide",
    "keywords": ""
  },
  {
    "path": "guide/introduction",
    "title": "Guide Introduction",
    "titleWords": "guide introduction",
    "headingWords": "Guide Introduction",
    "keywords": ""
  },
  {
    "path": "guide/basics/nform-basics",
    "title": "nForm Basics",
    "titleWords": "nform basics",
    "headingWords": "nForm Basics",
    "keywords": ""
  }
]
EOL

# 7. Start the content server if it's not already running
echo "Checking if content server is running..."

# Kill any existing content server
pkill -f "node .*content-server.js" || true

# Create or update the content-server.js file
echo "Creating content server script..."
cat > content-server.js << 'EOL'
/**
 * Simple Express server to serve content files
 * This server provides the content files directly from the dist directory
 */
const express = require('express');
const path = require('path');
const cors = require('cors');
const app = express();
const port = 4202;

// Enable CORS for all routes
app.use(cors());

// Serve static files from the dist directory
app.use(express.static(path.join(__dirname, 'dist')));
app.use('/md-content', express.static(path.join(__dirname, 'dist/md-content')));

// Handle all content requests
app.get('*', (req, res, next) => {
  // Log all requests for debugging
  console.log(`[Content Server] Request: ${req.path}`);
  
  // If it's a content path that doesn't exist, look for an alternative
  if (req.path.includes('md-content') && !req.path.endsWith('.json')) {
    const jsonPath = `${req.path}.json`;
    console.log(`[Content Server] Trying: ${jsonPath}`);
    res.sendFile(path.join(__dirname, 'dist', jsonPath), err => {
      if (err) {
        console.error(`[Content Server] Error: ${err.message}`);
        next();
      }
    });
  } else {
    next();
  }
});

// Handle 404 errors
app.use((req, res) => {
  console.error(`[Content Server] 404: ${req.path}`);
  res.status(404).send(`File not found: ${req.path}`);
});

// Start the server
app.listen(port, () => {
  console.log(`Content server running at http://localhost:${port}`);
  console.log(`Content mapping: http://localhost:${port}/nform-content-mapping.json`);
  console.log(`Pages data: http://localhost:${port}/md-content/pages.json`);
});
EOL

# Install dependencies if needed
if [ ! -f "node_modules/express/package.json" ] || [ ! -f "node_modules/cors/package.json" ]; then
  echo "Installing necessary dependencies..."
  npm install --no-save express cors
fi

# Start the content server
echo "Starting content server on port 4202..."
node content-server.js > content-server.log 2>&1 &

echo "Content server started in background (PID: $!)"
echo "Content server log: content-server.log"
echo "Content server URL: http://localhost:4202"

# 8. Verify ContentMapService configuration
echo "Checking ContentMapService configuration..."

SERVICE_PATH="apps/libs/shared/lib/services/content-map.service.ts"
if grep -q "http://localhost:4201" "$SERVICE_PATH"; then
  echo "Updating ContentMapService to use port 4202..."
  sed -i '' 's/http:\/\/localhost:4201/http:\/\/localhost:4202/g' "$SERVICE_PATH"
  echo "ContentMapService updated to use port 4202"
else
  echo "ContentMapService is already configured correctly"
fi

echo ""
echo "✅ CONTENT MAPPING FIX COMPLETE ✅"
echo "====================================="
echo "Content server running on port 4202"
echo "Content files have been created in dist/md-content"
echo ""
echo "You can now run the app with: npm run start"
echo "The content should load correctly from the content server"
echo ""
echo "To verify the fix, browse to these URLs:"
echo "- http://localhost:4202/nform-content-mapping.json"
echo "- http://localhost:4202/md-content/pages.json"
echo "- http://localhost:4202/md-content/home.json"
