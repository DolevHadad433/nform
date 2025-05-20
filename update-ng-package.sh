#!/bin/bash

# Script to update ng-package.json files for Angular 16 compatibility

# Update utils ng-package.json to add assets
cat > ./libs/utils/ng-package.json << 'EOL'
{
  "$schema": "../../node_modules/ng-packagr/ng-package.schema.json",
  "dest": "../../dist/@pebula/utils",
  "lib": {
    "entryFile": "src/index.ts"
  },
  "assets": [
    {
      "glob": "README.md",
      "input": "./libs/utils",
      "output": "."
    },
    {
      "glob": "LICENSE",
      "input": ".",
      "output": "."
    }
  ]
}
EOL

# Update metap ng-package.json to add assets
cat > ./libs/metap/ng-package.json << 'EOL'
{
  "$schema": "../../node_modules/ng-packagr/ng-package.schema.json",
  "dest": "../../dist/@pebula/metap",
  "lib": {
    "entryFile": "src/index.ts"
  },
  "assets": [
    {
      "glob": "README.md",
      "input": "./libs/metap",
      "output": "."
    },
    {
      "glob": "LICENSE",
      "input": ".",
      "output": "."
    }
  ]
}
EOL

# Update nform ng-package.json to add assets
cat > ./libs/nform/ng-package.json << 'EOL'
{
  "$schema": "../../node_modules/ng-packagr/ng-package.schema.json",
  "dest": "../../dist/@pebula/nform",
  "lib": {
    "entryFile": "src/index.ts"
  },
  "assets": [
    {
      "glob": "README.md",
      "input": ".",
      "output": "."
    },
    {
      "glob": "LICENSE",
      "input": ".",
      "output": "."
    },
    {
      "glob": "*.scss",
      "input": "libs/nform",
      "output": "."
    },
    {
      "glob": "**/*.scss",
      "input": "libs/nform/theming",
      "output": "theming"
    },
    {
      "glob": "*/theming/**/*.scss",
      "input": "libs/nform",
      "output": "."
    }
  ]
}
EOL

# Update nform-material ng-package.json to add assets
cat > ./libs/nform-material/ng-package.json << 'EOL'
{
  "$schema": "../../node_modules/ng-packagr/ng-package.schema.json",
  "dest": "../../dist/@pebula/nform-material",
  "lib": {
    "entryFile": "src/index.ts"
  },
  "assets": [
    {
      "glob": "README.md",
      "input": ".",
      "output": "."
    },
    {
      "glob": "LICENSE",
      "input": ".",
      "output": "."
    },
    {
      "glob": "*.scss",
      "input": "libs/nform-material",
      "output": "."
    },
    {
      "glob": "**/*.scss",
      "input": "libs/nform-material/theming",
      "output": "theming"
    },
    {
      "glob": "*/theming/**/*.scss",
      "input": "libs/nform-material",
      "output": "."
    }
  ]
}
EOL

echo "Updated ng-package.json files for Angular 16 compatibility"
