#!/bin/bash
# Update project.json to use custom webpack builder

echo "Updating project.json to use custom webpack builder..."

# Path to project.json
PROJECT_JSON="apps/nform-demo-app/project.json"

# Create a temporary file
TMP_FILE=$(mktemp)

# Check if project.json exists
if [ ! -f "$PROJECT_JSON" ]; then
  echo "Error: project.json not found at $PROJECT_JSON"
  exit 1
fi

# Read current executor
CURRENT_EXECUTOR=$(grep -o '"executor": "[^"]*"' "$PROJECT_JSON" | head -1)
echo "Current executor: $CURRENT_EXECUTOR"

# Prepare the sed command for macOS or Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  sed -i '' 's/"executor": "@angular-devkit\/build-angular:browser"/"executor": ".\/build:custom-webpack"/g' "$PROJECT_JSON"
else
  # Linux
  sed -i 's/"executor": "@angular-devkit\/build-angular:browser"/"executor": ".\/build:custom-webpack"/g' "$PROJECT_JSON"
fi

echo "Updated project.json to use custom webpack builder"

# Update package.json to add our custom builder
if grep -q '"@nform/custom-builder"' package.json; then
  echo "Custom builder already in package.json"
else
  # Add the builder to package.json
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' '/"dependencies": {/a\
    "@nform/custom-builder": "file:apps/nform-demo-app/build",
' package.json
  else
    # Linux
    sed -i '/"dependencies": {/a\    "@nform/custom-builder": "file:apps/nform-demo-app/build",' package.json
  fi
  echo "Added custom builder to package.json"
fi

echo "Project configured to use custom webpack builder"
