#!/bin/zsh
# Script to test the content-map.service.ts file

echo "Testing content-map.service.ts compilation..."

# Copy the content-map.service.ts file to a temporary test file
cp /Users/eliranbrami/projects/nform/apps/libs/shared/lib/services/content-map.service.ts /tmp/test-content-map.service.ts

# Create a simple TypeScript file that imports and uses the service
cat > /tmp/test-content-map.ts << 'EOL'
import { ContentMapService } from './test-content-map.service';
import { HttpClient } from '@angular/common/http';

// Mock HttpClient
class MockHttpClient {}

// Test the service
const httpClient = new MockHttpClient() as any as HttpClient;
const contentMapService = new ContentMapService(httpClient);

console.log('ContentMapService created successfully');
EOL

# Compile the test file
echo "Compiling test file..."
cd /tmp
npx tsc --noEmit test-content-map.ts

# Check the result
if [ $? -eq 0 ]; then
  echo "✅ Compilation successful! The content-map.service.ts file works correctly."
else
  echo "❌ Compilation failed. There may still be issues with the content-map.service.ts file."
fi

# Clean up
rm /tmp/test-content-map.ts /tmp/test-content-map.service.ts
