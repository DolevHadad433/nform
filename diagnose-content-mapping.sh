#!/bin/zsh
# Script to check and fix content mapping issues in the nform project
# This script provides diagnostic information and fixes for content mapping 404 errors

print_header() {
  echo "\033[1;34m==== $1 ====\033[0m"
}

print_success() {
  echo "\033[1;32m✅ $1\033[0m"
}

print_warning() {
  echo "\033[1;33m⚠️  $1\033[0m"
}

print_error() {
  echo "\033[1;31m❌ $1\033[0m"
}

# Header
print_header "NFORM Content Mapping Diagnostic Tool"
echo "This tool checks and fixes issues related to the nform-content-mapping.json file"
echo "Run this if you're seeing 404 errors for content mapping files"
echo ""

# Check if server is running
print_header "Checking if development server is running..."
if nc -z localhost 4201 >/dev/null 2>&1; then
  print_success "Development server is running on port 4201"
  SERVER_RUNNING=true
else
  print_warning "Development server doesn't appear to be running on port 4201"
  SERVER_RUNNING=false
fi

# Check for content mapping files
print_header "Checking for content mapping files..."

# Check dist directory
if [[ -f "dist/nform-content-mapping.json" ]]; then
  print_success "Found nform-content-mapping.json in dist directory"
else
  print_error "Missing nform-content-mapping.json in dist directory"
  MISSING_DIST_FILE=true
fi

# Check src directory
if [[ -f "apps/nform-demo-app/src/nform-content-mapping.json" ]]; then
  print_success "Found nform-content-mapping.json in src directory"
else
  print_error "Missing nform-content-mapping.json in src directory"
  MISSING_SRC_FILE=true
fi

# Check md-content directories
echo ""
echo "Checking md-content directories..."
if [[ -d "dist/md-content" ]]; then
  print_success "Found md-content directory in dist"
  
  # Check if it has the required files
  if [[ -f "dist/md-content/pages.json" && -f "dist/md-content/code-examples.json" && -f "dist/md-content/search-content.json" ]]; then
    print_success "Found required JSON files in dist/md-content"
    
    # Check if search-content.json has the correct structure
    if grep -q '"path": "/' "dist/md-content/search-content.json"; then
      print_success "search-content.json has correct structure"
    else
      print_warning "search-content.json doesn't have the expected structure"
      INCORRECT_SEARCH_CONTENT=true
    fi
  else
    print_error "Missing required JSON files in dist/md-content"
    MISSING_DIST_JSON=true
  fi
else
  print_error "Missing md-content directory in dist"
  MISSING_DIST_DIR=true
fi

if [[ -d "apps/nform-demo-app/src/md-content" ]]; then
  print_success "Found md-content directory in src"
  
  # Check if it has the required files
  if [[ -f "apps/nform-demo-app/src/md-content/pages.json" && -f "apps/nform-demo-app/src/md-content/code-examples.json" && -f "apps/nform-demo-app/src/md-content/search-content.json" ]]; then
    print_success "Found required JSON files in src/md-content"
  else
    print_error "Missing required JSON files in src/md-content"
    MISSING_SRC_JSON=true
  fi
else
  print_error "Missing md-content directory in src"
  MISSING_SRC_DIR=true
fi

# Check project.json configuration
print_header "Checking Angular project configuration..."
if grep -q '"apps/nform-demo-app/src/nform-content-mapping.json"' "apps/nform-demo-app/project.json" && 
   grep -q '"apps/nform-demo-app/src/md-content"' "apps/nform-demo-app/project.json"; then
  print_success "Project configuration includes content mapping files in assets"
else
  print_error "Project configuration is missing content mapping files in assets"
  MISSING_CONFIG=true
fi

# Check HTTP accessibility if server is running
if [[ "$SERVER_RUNNING" == true ]]; then
  print_header "Testing HTTP accessibility of content files..."
  
  # Function to test URL
  test_url() {
    local url=$1
    local response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    
    if [[ "$response" == "200" ]]; then
      print_success "$url is accessible (HTTP 200)"
      return 0
    else
      print_error "$url returns HTTP $response"
      return 1
    fi
  }
  
  test_url "http://localhost:4201/nform-content-mapping.json"
  test_url "http://localhost:4201/md-content/pages.json"
  test_url "http://localhost:4201/md-content/code-examples.json"
  test_url "http://localhost:4201/md-content/search-content.json"
fi

# Apply fixes if needed
print_header "Fixes"
if [[ "$MISSING_DIST_FILE" == true || "$MISSING_DIST_DIR" == true || "$MISSING_DIST_JSON" == true || 
      "$MISSING_SRC_FILE" == true || "$MISSING_SRC_DIR" == true || "$MISSING_SRC_JSON" == true || 
      "$MISSING_CONFIG" == true ]]; then
  
  echo "Issues were detected. Would you like to apply the comprehensive fix? (y/n)"
  read answer
  
  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    echo "Applying comprehensive fix..."
    
    # Generate content mapping files
    echo "Generating content files..."
    node ./tools/generate-content-mapping.js
    
    # Copy to src directory
    echo "Copying files to src directory..."
    mkdir -p apps/nform-demo-app/src/md-content
    cp dist/nform-content-mapping.json apps/nform-demo-app/src/
    cp dist/md-content/*.json apps/nform-demo-app/src/md-content/
    
    # Update project.json if needed
    if [[ "$MISSING_CONFIG" == true ]]; then
      echo "Updating project configuration..."
      # Backup first
      cp apps/nform-demo-app/project.json apps/nform-demo-app/project.json.content-fix-backup
      
      # Update project.json - this is a simplified approach, might need manual checking
      sed -i '' 's/"assets": \[/"assets": \[\n          "apps\/nform-demo-app\/src\/nform-content-mapping.json",\n          "apps\/nform-demo-app\/src\/md-content",/g' apps/nform-demo-app/project.json
    fi
    
    print_success "Fix applied successfully!"
    
    if [[ "$SERVER_RUNNING" == true ]]; then
      echo "Would you like to restart the development server? (y/n)"
      read restart
      
      if [[ "$restart" == "y" || "$restart" == "Y" ]]; then
        echo "Restarting development server..."
        pkill -f "ng serve" || echo "No running Angular server found"
        nx serve nform-demo-app &
        echo "Development server restarting..."
      fi
    else
      echo "To apply the changes, start the development server with:"
      echo "nx serve nform-demo-app"
    fi
  else
    echo "No fixes applied. You can run ./fix-content-mapping-final.sh manually to fix the issues."
  fi
else
  print_success "No issues detected with content mapping files!"
fi

print_header "More Information"
echo "For detailed documentation about content mapping in this project, see:"
echo "- docs/CONTENT_MAPPING_COMPLETE_GUIDE.md"
echo "- docs/NFORM_CONTENT_MAPPING_ISSUE.md"
echo ""
echo "If you're still experiencing issues, try running: ./fix-content-mapping-final.sh"
