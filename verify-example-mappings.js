#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

console.log('🔍 Verifying Example Component Mappings...\n');

// Extract selectors from generated content files
function extractSelectorsFromGeneratedContent() {
  const contentDir = 'dist/md-content';
  const allSelectors = new Set();
  
  function scanContentFiles(dir) {
    if (!fs.existsSync(dir)) return;
    
    const items = fs.readdirSync(dir);
    items.forEach(item => {
      const fullPath = path.join(dir, item);
      const stat = fs.statSync(fullPath);
      
      if (stat.isDirectory()) {
        scanContentFiles(fullPath);
      } else if (item.endsWith('.json')) {
        try {
          const content = fs.readFileSync(fullPath, 'utf8');
          const data = JSON.parse(content);
          
          if (data.contents) {
            // Find all pbl-example-view references
            const matches = data.contents.match(/pbl-example-view="([^"]+)"/g);
            if (matches) {
              matches.forEach(match => {
                const selector = match.match(/pbl-example-view="([^"]+)"/)[1];
                allSelectors.add(selector);
              });
            }
          }
        } catch (e) {
          // Skip invalid JSON files
        }
      }
    });
  }
  
  scanContentFiles(contentDir);
  console.log(`📄 Found ${allSelectors.size} unique example selectors in generated content files`);
  
  return Array.from(allSelectors).sort();
}

// Extract actual selectors from example components
function extractActualExampleSelectors() {
  const contentDir = 'apps/nform-demo-app/content';
  const actualSelectors = new Set();
  
  function scanDirectory(dir) {
    if (!fs.existsSync(dir)) return;
    
    const items = fs.readdirSync(dir);
    items.forEach(item => {
      const fullPath = path.join(dir, item);
      const stat = fs.statSync(fullPath);
      
      if (stat.isDirectory()) {
        scanDirectory(fullPath);
      } else if (item.endsWith('.component.ts')) {
        const content = fs.readFileSync(fullPath, 'utf8');
        
        // Look for @Example decorator
        const exampleMatch = content.match(/@Example\('([^']+)'/);
        if (exampleMatch) {
          actualSelectors.add(exampleMatch[1]);
        }
      }
    });
  }
  
  scanDirectory(contentDir);
  return Array.from(actualSelectors).sort();
}

// Main verification
const generatedSelectors = extractSelectorsFromGeneratedContent();
const actualSelectors = extractActualExampleSelectors();

console.log('\n📊 VERIFICATION RESULTS:\n');

console.log('🎯 Selectors used in generated content:');
generatedSelectors.forEach(selector => console.log(`   - ${selector}`));

console.log('\n✅ Actual example component selectors:');
actualSelectors.forEach(selector => console.log(`   - ${selector}`));

console.log('\n🔍 ANALYSIS:\n');

// Check for mismatches
const generatedSet = new Set(generatedSelectors);
const actualSet = new Set(actualSelectors);

const missingInActual = generatedSelectors.filter(s => !actualSet.has(s));
const missingInGenerated = actualSelectors.filter(s => !generatedSet.has(s));

if (missingInActual.length > 0) {
  console.log('❌ ERRORS - Selectors used in generated content but not found in actual components:');
  missingInActual.forEach(selector => console.log(`   - ${selector}`));
} else {
  console.log('✅ All generated content selectors have corresponding components!');
}

if (missingInGenerated.length > 0) {
  console.log('\n⚠️  WARNING - Example components not used in any generated content:');
  missingInGenerated.forEach(selector => console.log(`   - ${selector}`));
} else {
  console.log('\n✅ All example components are used in generated content!');
}

console.log(`\n📈 SUMMARY:`);
console.log(`   Generated content references: ${generatedSelectors.length} selectors`);
console.log(`   Actual example components: ${actualSelectors.length} selectors`);
console.log(`   Mapping errors: ${missingInActual.length}`);
console.log(`   Unused components: ${missingInGenerated.length}`);

if (missingInActual.length === 0) {
  console.log('\n🎉 SUCCESS: All example component mappings are correct!');
} else {
  console.log('\n🚨 FAILURE: There are mapping errors that need to be fixed.');
  process.exit(1);
}
