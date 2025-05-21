#!/bin/zsh
# Test script to verify content mapping in nform
# This script can be run at any time to verify that content mapping is working correctly

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "${BLUE}===== NFORM Content Mapping Test =====${NC}"
echo "This script tests if content mapping files are correctly accessible"

# Function to test URL
test_url() {
  local url=$1
  local response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  local content=$(curl -s "$url")
  
  echo -n "Testing $url... "
  if [[ "$response" == "200" ]]; then
    echo "${GREEN}OK (HTTP 200)${NC}"
    echo "Content: $content"
    return 0
  else
    echo "${RED}FAILED (HTTP $response)${NC}"
    return 1
  fi
}

# Check if server is running
if ! nc -z localhost 4201 >/dev/null 2>&1; then
  echo "${RED}Error: Development server is not running on port 4201.${NC}"
  echo "Please start the server with: nx serve nform-demo-app"
  exit 1
fi

# Test main mapping file
echo "${BLUE}\nTesting main mapping file:${NC}"
test_url "http://localhost:4201/nform-content-mapping.json" || FAILED=true

# Test md-content files
echo "${BLUE}\nTesting md-content files:${NC}"
test_url "http://localhost:4201/md-content/pages.json" || FAILED=true
test_url "http://localhost:4201/md-content/code-examples.json" || FAILED=true
test_url "http://localhost:4201/md-content/search-content.json" || FAILED=true

# Test ContentMapService via console logs
echo "${BLUE}\nFor full verification:${NC}"
echo "1. Open browser developer console"
echo "2. Look for logs from [ContentMapService]"
echo "3. Verify that mapping was loaded successfully"

if [[ "$FAILED" == true ]]; then
  echo "${RED}\nSome tests failed. Run ./diagnose-content-mapping.sh to fix issues.${NC}"
  exit 1
else
  echo "${GREEN}\nAll tests passed! Content mapping is working correctly.${NC}"
  exit 0
fi
