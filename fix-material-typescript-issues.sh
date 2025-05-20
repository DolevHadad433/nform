#!/bin/bash

# Fix TypeScript issues in nform-material for Angular 16 compatibility

# Fix entryComponents in module.ts - Remove entryComponents, they are not needed in Angular 16
sed -i '' '/entryComponents:/d' libs/nform-material/src/lib/module.ts
sed -i '' '/\[MaterialTemplateStoreComponent, MaterialFormControlRenderer\]/d' libs/nform-material/src/lib/module.ts

# Fix BooleanInput issue in material-form-control-renderer.component.ts
# First, find the showLabels property and ensure it's properly typed
sed -i '' 's/@Input() showLabels: BooleanInput/@Input() showLabels = false/g' libs/nform-material/src/lib/renderer/material-form-control-renderer/material-form-control-renderer.component.ts

echo "Fixed TypeScript issues in nform-material for Angular 16 compatibility"
