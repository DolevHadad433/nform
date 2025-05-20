#!/bin/zsh

# Go to project root folder
cd /Users/eliranbrami/projects/nform

# Create a backup of the current state
echo "Creating backup of the project..."
timestamp=$(date +%Y%m%d%H%M%S)
backup_dir="/Users/eliranbrami/projects/nform-backup-$timestamp"
mkdir -p $backup_dir
cp -r . $backup_dir
echo "Backup created at $backup_dir"

# Replace @nrwl references with @nx in package.json
echo "Updating package.json references..."
sed -i '' 's/"@nrwl\//"@nx\//g' package.json

# Replace @nrwl references with @nx in all JSON files
echo "Updating JSON files..."
find . -name "*.json" -type f -not -path "*/node_modules/*" -not -path "*/dist/*" -exec sed -i '' 's/"@nrwl\//"@nx\//g' {} \;

# Replace @nrwl imports with @nx in all TypeScript and JavaScript files
echo "Updating TypeScript and JavaScript imports..."
find . -name "*.ts" -o -name "*.js" -type f -not -path "*/node_modules/*" -not -path "*/dist/*" -exec sed -i '' 's/from "@nrwl\//from "@nx\//g' {} \;
find . -name "*.ts" -o -name "*.js" -type f -not -path "*/node_modules/*" -not -path "*/dist/*" -exec sed -i '' "s/from '@nrwl\//from '@nx\//g" {} \;
find . -name "*.ts" -o -name "*.js" -type f -not -path "*/node_modules/*" -not -path "*/dist/*" -exec sed -i '' 's/import "@nrwl\//import "@nx\//g' {} \;
find . -name "*.ts" -o -name "*.js" -type f -not -path "*/node_modules/*" -not -path "*/dist/*" -exec sed -i '' "s/import '@nrwl\//import '@nx\//g" {} \;
find . -name "*.ts" -o -name "*.js" -type f -not -path "*/node_modules/*" -not -path "*/dist/*" -exec sed -i '' 's/require("@nrwl\//require("@nx\//g' {} \;
find . -name "*.ts" -o -name "*.js" -type f -not -path "*/node_modules/*" -not -path "*/dist/*" -exec sed -i '' "s/require('@nrwl\//require('@nx\//g" {} \;

# Replace executor references in project.json files
echo "Updating executor references in project.json files..."
find . -name "project.json" -type f -not -path "*/node_modules/*" -not -path "*/dist/*" -exec sed -i '' 's/"executor": "@nrwl\//"executor": "@nx\//g' {} \;

# Update nx.json file
echo "Updating nx.json..."
sed -i '' 's/@nrwl\/angular/@nx\/angular/g' nx.json

# Update script section in package.json
echo "Updating package.json scripts..."
sed -i '' 's/\.\/node_modules\/\.bin\/nx/nx/g' package.json
sed -i '' 's/\.\/.bin\/nx/nx/g' package.json
sed -i '' 's/ng update @nrwl\/workspace/nx migrate latest/g' package.json

echo "NX path updates completed. Please check for any errors and test the project."
