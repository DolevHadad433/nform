#!/bin/zsh

# Master script to run all Angular 16 upgrade steps
cd /Users/eliranbrami/projects/nform

# Print header
echo "=================================================="
echo "Angular 16 and NX 16 Upgrade Process"
echo "=================================================="
echo "Starting upgrade process at $(date)"
echo ""

# Step 1: Back up the project
echo "Step 1: Creating a full project backup..."
timestamp=$(date +%Y%m%d%H%M%S)
backup_dir="/Users/eliranbrami/projects/nform-backup-$timestamp"
mkdir -p $backup_dir
cp -r . $backup_dir
echo "✓ Backup created at $backup_dir"
echo ""

# Step 2: Update NX paths from @nrwl to @nx
echo "Step 2: Updating NX paths from @nrwl to @nx..."
./update-nx-paths.sh
echo "✓ NX paths updated"
echo ""

# Step 3: Update Angular and NX package versions
echo "Step 3: Upgrading package versions to Angular 16 and NX 16..."
./upgrade-to-angular16.sh
echo "✓ Package versions updated"
echo ""

# Step 4: Update webpack configurations
echo "Step 4: Updating webpack configurations for Angular 16..."
./update-webpack-config.sh
echo "✓ Webpack configurations updated"
echo ""

# Step 5: Clean up the project
echo "Step 5: Cleaning yarn cache and node_modules..."
yarn cache clean
rm -rf node_modules
echo "✓ Project cleaned"
echo ""

# Step 6: Reinstall dependencies
echo "Step 6: Reinstalling dependencies..."
yarn install
echo "✓ Dependencies reinstalled"
echo ""

# Step 7: Run NX migration if needed
echo "Step 7: Running NX migrations..."
yarn nx migrate latest
echo "✓ NX migration commands generated"
echo ""
echo "To apply the migrations, run: yarn nx migrate --run-migrations"
echo ""

# Step 8: Build the project
echo "Step 8: Building the project to test the upgrade..."
yarn build-lib
echo "✓ Library build completed"
echo ""

echo "=================================================="
echo "Angular 16 and NX 16 Upgrade Process Completed"
echo "=================================================="
echo "Please review any errors that occurred during the process"
echo "and address them manually if needed."
echo ""
echo "Next steps:"
echo "1. Run 'yarn nx migrate --run-migrations' to apply NX migrations"
echo "2. Test your application thoroughly"
echo "3. Fix any TypeScript or runtime errors"
echo "4. Update your CI/CD pipelines if necessary"
echo ""
echo "Upgrade process completed at $(date)"
