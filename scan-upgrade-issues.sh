#!/bin/zsh

# Analysis script to identify potential issues with the Angular 16 upgrade
cd /Users/eliranbrami/projects/nform

echo "=================================================="
echo "Angular 16 Upgrade - Potential Issues Scanner"
echo "=================================================="
echo ""

# Check for deprecated ViewEncapsulation.Native
echo "Checking for ViewEncapsulation.Native usage..."
count=$(grep -r "ViewEncapsulation.Native" --include="*.ts" . | wc -l)
if [ $count -gt 0 ]; then
  echo "⚠️ Found $count instances of ViewEncapsulation.Native which is deprecated."
  echo "   Replace with ViewEncapsulation.ShadowDom instead."
  grep -r "ViewEncapsulation.Native" --include="*.ts" .
else
  echo "✓ No ViewEncapsulation.Native usage found."
fi
echo ""

# Check for HttpClient deprecated methods
echo "Checking for deprecated HttpClient methods..."
deprecated_methods=("get<T>" "post<T>" "put<T>" "delete<T>" "jsonp<T>" "patch<T>")
found=false

for method in "${deprecated_methods[@]}"; do
  count=$(grep -r "$method" --include="*.ts" . | wc -l)
  if [ $count -gt 0 ]; then
    echo "⚠️ Found potential usage of deprecated HttpClient.$method."
    echo "   Consider updating to the newer syntax."
    found=true
  fi
done

if [ "$found" = false ]; then
  echo "✓ No obvious deprecated HttpClient methods found."
fi
echo ""

# Check for deprecated RxJS imports
echo "Checking for deprecated RxJS imports..."
count=$(grep -r "import.*from 'rxjs/.*'" --include="*.ts" . | wc -l)
if [ $count -gt 0 ]; then
  echo "⚠️ Found $count instances of deep imports from RxJS which are deprecated."
  echo "   Use import from 'rxjs' or 'rxjs/operators' instead."
  grep -r "import.*from 'rxjs/.*'" --include="*.ts" . | grep -v "operators" | head -10
else
  echo "✓ No deprecated RxJS imports found."
fi
echo ""

# Check for ngcc references
echo "Checking for ngcc references..."
count=$(grep -r "ngcc" --include="*.json" --include="*.js" . | wc -l)
if [ $count -gt 0 ]; then
  echo "⚠️ Found $count references to ngcc which is no longer used in Angular 16."
  echo "   These configurations can be removed."
  grep -r "ngcc" --include="*.json" --include="*.js" .
else
  echo "✓ No ngcc references found."
fi
echo ""

# Check for ViewChild without static flag
echo "Checking for ViewChild without static flag..."
count=$(grep -r "@ViewChild" --include="*.ts" . | grep -v "static:" | wc -l)
if [ $count -gt 0 ]; then
  echo "⚠️ Found $count potential ViewChild decorators without static flag."
  echo "   Consider adding {static: false} or {static: true} as appropriate."
else
  echo "✓ No obvious ViewChild issues found."
fi
echo ""

# Check for Material imports that need updating
echo "Checking for Angular Material imports that might need updating..."
count=$(grep -r "import.*'@angular/material/" --include="*.ts" . | wc -l)
if [ $count -gt 0 ]; then
  echo "⚠️ Found $count Angular Material imports that might need to be updated."
  echo "   Consider adding '/legacy' for components that need legacy versions."
else
  echo "✓ No obvious Angular Material import issues found."
fi
echo ""

echo "Analysis complete. Please review any warnings and address them manually."
echo "=================================================="
