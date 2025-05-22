// Define webpack constants for Angular version and CDK version
const path = require("path");
const fs = require("fs");

// Use package.json to get actual versions
const packageJson = require("../package.json");
const angularVersion = packageJson.dependencies["@angular/core"].replace("^", "");
const cdkVersion = packageJson.dependencies["@angular/cdk"].replace("^", "");
const nformVersion = packageJson.version;

// Create a constants file for direct import
const constants = {
  ANGULAR_VERSION: angularVersion,
  CDK_VERSION: cdkVersion,
  NFORM_VERSION: nformVersion,
  BUILD_VERSION: "dev-build-" + new Date().toISOString().slice(0, 10)
};

// Output to a JSON file
const outputFile = path.resolve(__dirname, "../dist/webpack-constants.json");
const outputDir = path.dirname(outputFile);

if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

fs.writeFileSync(outputFile, JSON.stringify(constants, null, 2));
console.log("Generated webpack constants: ", constants);
