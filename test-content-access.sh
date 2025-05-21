#!/bin/zsh
# Test script to check file accessibility

echo "Testing content mapping files accessibility..."

# Function to test URL access
test_url() {
  local url=$1
  local response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  
  if [[ "$response" == "200" ]]; then
    echo "✅ $url - OK (200)"
  else
    echo "❌ $url - ERROR (HTTP $response)"
  fi
}

# Test the main content mapping file
test_url "http://localhost:4201/assets/nform-content-mapping.json"

# Test the referenced files
test_url "http://localhost:4201/assets/md-content/pages.json"
test_url "http://localhost:4201/assets/md-content/code-examples.json" 
test_url "http://localhost:4201/assets/md-content/search-content.json"

# Also test direct access
test_url "http://localhost:4201/md-content/pages.json"
test_url "http://localhost:4201/md-content/code-examples.json"
test_url "http://localhost:4201/md-content/search-content.json"
