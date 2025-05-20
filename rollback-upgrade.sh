#!/bin/zsh

# Script to rollback the Angular 16 upgrade if needed
cd /Users/eliranbrami/projects/nform

echo "=================================================="
echo "Angular 16 Upgrade - Rollback Script"
echo "=================================================="
echo ""

# List available backups
echo "Available backup directories:"
ls -lad /Users/eliranbrami/projects/nform-backup-* | sort -r

echo ""
echo "Enter the backup directory you want to restore from:"
read backup_dir

if [ ! -d "$backup_dir" ]; then
  echo "Error: Directory $backup_dir does not exist."
  exit 1
fi

echo ""
echo "⚠️ WARNING: This will replace your current project with the backup."
echo "All changes made since the backup will be lost."
echo "Are you sure you want to proceed? (y/n)"
read confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
  echo "Rollback canceled."
  exit 0
fi

echo ""
echo "Rolling back to backup at $backup_dir..."

# Clean current directory (except for node_modules to save time)
find . -mindepth 1 -maxdepth 1 -not -name "node_modules" -exec rm -rf {} \;

# Copy from backup
cp -r $backup_dir/* .

echo ""
echo "Cleaning and reinstalling dependencies..."
yarn cache clean
rm -rf node_modules
yarn install

echo ""
echo "✓ Rollback completed successfully."
echo "=================================================="
