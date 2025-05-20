#!/bin/zsh

# Go to project root folder
cd /Users/eliranbrami/projects/nform

# Backup package.json before making changes
cp package.json package.json.backup-$(date +%Y%m%d)

# Update Angular packages to version 16
yarn upgrade --ignore-engines \
  @angular/animations@16.1.0 \
  @angular/cdk@16.1.0 \
  @angular/cdk-experimental@16.1.0 \
  @angular/common@16.1.0 \
  @angular/compiler@16.1.0 \
  @angular/core@16.1.0 \
  @angular/elements@16.1.0 \
  @angular/forms@16.1.0 \
  @angular/localize@16.1.0 \
  @angular/material@16.1.0 \
  @angular/platform-browser@16.1.0 \
  @angular/platform-browser-dynamic@16.1.0 \
  @angular/platform-server@16.1.0 \
  @angular/router@16.1.0

# Update Angular CLI and build tools
yarn upgrade --ignore-engines \
  @angular-devkit/build-angular@16.1.0 \
  @angular-devkit/schematics@16.1.0 \
  @angular/cli@16.1.0 \
  @angular/compiler-cli@16.1.0 \
  @angular/language-service@16.1.0

# Update Universal packages
yarn upgrade --ignore-engines \
  @nguniversal/common@16.1.0 \
  @nguniversal/express-engine@16.1.0

# Update NX packages
yarn upgrade --ignore-engines \
  nx@16.5.0 \
  @nx/angular@16.5.0 \
  @nx/cypress@16.5.0 \
  @nx/devkit@16.5.0 \
  @nx/express@16.5.0 \
  @nx/jest@16.5.0 \
  @nx/js@16.5.0 \
  @nx/node@16.5.0 \
  @nx/workspace@16.5.0

# Update NgRx packages 
yarn upgrade --ignore-engines \
  @ngrx/effects@16.0.0 \
  @ngrx/router-store@16.0.0 \
  @ngrx/store@16.0.0 \
  @ngrx/store-devtools@16.0.0 \
  @ngrx/schematics@16.0.0

# Update RxJS
yarn upgrade --ignore-engines \
  rxjs@^7.8.0

# Update Angular testing libraries
yarn upgrade --ignore-engines \
  jest-preset-angular@13.1.0

# Update TypeScript and other related packages
yarn upgrade --ignore-engines \
  typescript@~5.1.3 \
  zone.js@~0.13.0

# Update other packages
yarn upgrade --ignore-engines \
  tslib@^2.3.0 \
  @swc/helpers@~0.5.0

# Additional packages that need updates for compatibility
yarn upgrade --ignore-engines \
  ng-packagr@16.1.0 \
  ngx-build-plus@16.0.0

echo "Package upgrades completed. Please check for any errors in the output."
