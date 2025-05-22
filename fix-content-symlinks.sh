#!/bin/bash
# Script to create the right directory structure and symlinks for the content files

echo "Creating symlinks for content files..."

# Create the necessary directories in the browser dist directory
mkdir -p dist/browser/md-contentguide-intro
mkdir -p dist/browser/md-contentguide
mkdir -p dist/browser/md-contentquick-start
mkdir -p dist/browser/md-contentguide/basics/advanced-controls
mkdir -p dist/browser/md-contentguide/basics/disable
mkdir -p dist/browser/md-contentguide/basics/form-layout
mkdir -p dist/browser/md-contentguide/basics/form-layout-pinning
mkdir -p dist/browser/md-contentguide/basics/form-splitting
mkdir -p dist/browser/md-contentguide/basics/hot-binding
mkdir -p dist/browser/md-contentguide/basics/hide-filter-controls
mkdir -p dist/browser/md-contentguide/basics/model-form-sync
mkdir -p dist/browser/md-contentguide/basics/nform-basics
mkdir -p dist/browser/md-contentguide/basics/template-overrides
mkdir -p dist/browser/md-contentguide/basics/validation
mkdir -p dist/browser/md-contentguide/advanced-modeling/arrays
mkdir -p dist/browser/md-contentguide/advanced-modeling/child-forms
mkdir -p dist/browser/md-contentguide/advanced-modeling/controlling-nform
mkdir -p dist/browser/md-contentguide/advanced-modeling/complex-data-structures
mkdir -p dist/browser/md-contentguide/advanced-modeling/flattening
mkdir -p dist/browser/md-contentguide/events/before-render
mkdir -p dist/browser/md-contentguide/events/render-state
mkdir -p dist/browser/md-contentguide/events/field-sync-redraw
mkdir -p dist/browser/md-contentguide/events/value-changes
mkdir -p dist/browser/md-contentguide/layout/the-renderer

# Copy the content files to the browser dist directory
cp -f dist/md-content5e8f84b66fd66837.json dist/browser/md-content5e8f84b66fd66837.json
cp -f dist/md-contentguide-intro/6024bf20223e39a0.json dist/browser/md-contentguide-intro/6024bf20223e39a0.json
cp -f dist/md-contentguide/4095937b4d200c89.json dist/browser/md-contentguide/4095937b4d200c89.json
cp -f dist/md-contentquick-start/262c9362fd2f6e2f.json dist/browser/md-contentquick-start/262c9362fd2f6e2f.json
cp -f dist/md-contentguide/basics/advanced-controls/2ffcbbb6677ad0d6.json dist/browser/md-contentguide/basics/advanced-controls/2ffcbbb6677ad0d6.json
cp -f dist/md-contentguide/basics/disable/56565768d736b818.json dist/browser/md-contentguide/basics/disable/56565768d736b818.json
cp -f dist/md-contentguide/basics/form-layout/8eb74da852b329be.json dist/browser/md-contentguide/basics/form-layout/8eb74da852b329be.json
cp -f dist/md-contentguide/basics/form-layout-pinning/be74ed71d9e529f1.json dist/browser/md-contentguide/basics/form-layout-pinning/be74ed71d9e529f1.json
cp -f dist/md-contentguide/basics/form-splitting/b731676f726c2fb8.json dist/browser/md-contentguide/basics/form-splitting/b731676f726c2fb8.json
cp -f dist/md-contentguide/basics/hot-binding/4d2d70588211e135.json dist/browser/md-contentguide/basics/hot-binding/4d2d70588211e135.json
cp -f dist/md-contentguide/basics/hide-filter-controls/35940c759178f787.json dist/browser/md-contentguide/basics/hide-filter-controls/35940c759178f787.json
cp -f dist/md-contentguide/basics/model-form-sync/9bfa0bc6df9200d5.json dist/browser/md-contentguide/basics/model-form-sync/9bfa0bc6df9200d5.json
cp -f dist/md-contentguide/basics/nform-basics/7084a93229fa485c.json dist/browser/md-contentguide/basics/nform-basics/7084a93229fa485c.json
cp -f dist/md-contentguide/basics/template-overrides/067352f4533378e0.json dist/browser/md-contentguide/basics/template-overrides/067352f4533378e0.json
cp -f dist/md-contentguide/advanced-modeling/arrays/2353498babeddfea.json dist/browser/md-contentguide/advanced-modeling/arrays/2353498babeddfea.json
cp -f dist/md-contentguide/basics/validation/b271bf48786a8e1b.json dist/browser/md-contentguide/basics/validation/b271bf48786a8e1b.json
cp -f dist/md-contentguide/advanced-modeling/child-forms/0a858f07e4fbb45e.json dist/browser/md-contentguide/advanced-modeling/child-forms/0a858f07e4fbb45e.json
cp -f dist/md-contentguide/advanced-modeling/controlling-nform/dbe10b8c644b40da.json dist/browser/md-contentguide/advanced-modeling/controlling-nform/dbe10b8c644b40da.json
cp -f dist/md-contentguide/advanced-modeling/complex-data-structures/7bdb31691b15d130.json dist/browser/md-contentguide/advanced-modeling/complex-data-structures/7bdb31691b15d130.json
cp -f dist/md-contentguide/events/before-render/01787288f998d53b.json dist/browser/md-contentguide/events/before-render/01787288f998d53b.json
cp -f dist/md-contentguide/advanced-modeling/flattening/d9e210c19c649f9c.json dist/browser/md-contentguide/advanced-modeling/flattening/d9e210c19c649f9c.json
cp -f dist/md-contentguide/events/render-state/5cfed2ea2cf1a022.json dist/browser/md-contentguide/events/render-state/5cfed2ea2cf1a022.json
cp -f dist/md-contentguide/events/field-sync-redraw/471e2f05f2ad3a44.json dist/browser/md-contentguide/events/field-sync-redraw/471e2f05f2ad3a44.json
cp -f dist/md-contentguide/events/value-changes/a5327c9f51f8836d.json dist/browser/md-contentguide/events/value-changes/a5327c9f51f8836d.json
cp -f dist/md-contentguide/layout/the-renderer/f2b48b48beee4c2f.json dist/browser/md-contentguide/layout/the-renderer/f2b48b48beee4c2f.json

echo "Symlinks created successfully!"
echo "Remember to restart your dev server for changes to take effect."
