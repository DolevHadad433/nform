/**
 * Script to update project.json to use the custom webpack config
 */
const fs = require('fs');
const path = require('path');

const projectJsonPath = path.resolve(__dirname, 'apps/nform-demo-app/project.json');

try {
  // Read the current project.json
  const projectJson = JSON.parse(fs.readFileSync(projectJsonPath, 'utf8'));
  
  // Update the build target to use the custom webpack config
  if (projectJson.targets && projectJson.targets.build && projectJson.targets.build.options) {
    projectJson.targets.build.options.webpackConfig = "apps/nform-demo-app/build/webpack.content.js";
    console.log('Updated project.json to use the custom webpack config');
  } else {
    console.error('Could not find the build target in project.json');
  }
  
  // Write the updated project.json
  fs.writeFileSync(projectJsonPath, JSON.stringify(projectJson, null, 2));
  console.log('Successfully updated project.json');
} catch (error) {
  console.error('Error updating project.json:', error.message);
}
