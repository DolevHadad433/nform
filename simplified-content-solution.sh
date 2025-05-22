#!/bin/zsh
# Run a simplified content server and build with direct file generation

echo "=========== SIMPLIFIED CONTENT SOLUTION ==========="

# 1. Create content directories
mkdir -p dist/md-content

# 2. Create the proper pages.json structure
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

# 3. Create sample content files
cat > dist/md-content/home.json << 'EOL'
{
  "id": "home",
  "title": "Home",
  "contents": "# Welcome to NForm\n\nThis is the home page for the NForm documentation."
}
EOL

cat > dist/md-content/guide.json << 'EOL'
{
  "id": "guide",
  "title": "Guide",
  "contents": "# NForm Guide\n\nThis guide provides comprehensive documentation for using NForm."
}
EOL

cat > dist/md-content/guide-introduction.json << 'EOL'
{
  "id": "guide-introduction",
  "title": "Guide Introduction",
  "contents": "# Guide Introduction\n\nLearn how to get started with NForm."
}
EOL

cat > dist/md-content/guide-basics-nform-basics.json << 'EOL'
{
  "id": "guide-basics-nform-basics",
  "title": "nForm Basics",
  "contents": "# nForm Basics\n\nLearn the basic concepts of NForm."
}
EOL

# 4. Create the code examples file
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

# 5. Create the search content file
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

# 6. Create the mapping file
cat > dist/nform-content-mapping.json << 'EOL'
{
  "markdownPages": "md-content/pages.json",
  "markdownCodeExamples": "md-content/code-examples.json",
  "searchContent": "md-content/search-content.json"
}
EOL

# 7. Start the content server
echo "Starting content server on port 4202..."

if ! command -v npx &> /dev/null; then
  npm install -g npx
fi

# Check if express and cors are installed, install if not
if [ ! -f "node_modules/express/package.json" ] || [ ! -f "node_modules/cors/package.json" ]; then
  npm install --no-save express cors
fi

# Kill any existing content server processes
pkill -f "node .*content-server.js" || true

# Create a simple content server if it doesn't exist
if [ ! -f "content-server.js" ] || grep -q "port = 4201" "content-server.js"; then
  cat > content-server.js << 'EOL'
/**
 * Simple Express server to serve content files
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

// Special routes for content files with unconventional paths
app.get('/md-content*', (req, res) => {
  const filePath = path.join(__dirname, 'dist', req.path);
  res.sendFile(filePath, err => {
    if (err) {
      console.error(`Error serving ${req.path}: ${err.message}`);
      res.status(404).send(`File not found: ${req.path}`);
    }
  });
});

// Start the server
app.listen(port, () => {
  console.log(`Content server running at http://localhost:${port}`);
  console.log(`Content mapping accessible at http://localhost:${port}/nform-content-mapping.json`);
  console.log(`Pages data accessible at http://localhost:${port}/md-content/pages.json`);
});
EOL
  echo "Created new content-server.js with port 4202"
fi

# Start the content server
node content-server.js > content-server.log 2>&1 &
echo "Content server started in background, check content-server.log for details"
echo "Content server available at: http://localhost:4202"

echo "=========== CONTENT SOLUTION COMPLETE ==========="
echo "You can now serve the app with: npm run start"
echo "Make sure ContentMapService is using port 4202 for contentServerUrl"
echo "Try accessing the content at: http://localhost:4202/nform-content-mapping.json"
