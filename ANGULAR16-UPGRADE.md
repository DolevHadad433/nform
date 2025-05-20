# Angular 16 Upgrade Guide

This guide provides detailed instructions for upgrading this project from Angular 15.2.9 to Angular 16, along with NX 15.9.7 to NX 16.5.0.

## Prerequisites

- Ensure you have yarn installed
- Ensure you have enough disk space for a backup (~2x the project size)
- Commit any changes to your version control system before proceeding

## Upgrade Scripts

We've created several scripts to automate the upgrade process:

1. `update-nx-paths.sh` - Updates all references from `@nrwl/*` to `@nx/*`
2. `upgrade-to-angular16.sh` - Updates all package versions to Angular 16 and NX 16
3. `update-webpack-config.sh` - Updates webpack configurations for Angular 16 compatibility
4. `run-angular16-upgrade.sh` - Master script that runs all the above scripts in sequence

## Manual Steps Required

After running the automatic upgrade scripts, you might need to perform the following manual steps:

1. **Fix TypeScript Errors**: Angular 16 uses TypeScript 5.1, which might introduce some type errors.

2. **Update NGCC Configuration**: Angular 16 no longer uses the Angular Compatibility Compiler (ngcc).

3. **Update ViewEncapsulation**: If you use `ViewEncapsulation.Native`, replace it with `ViewEncapsulation.ShadowDom`.

4. **Review Deprecated APIs**: Check for usage of deprecated APIs that were removed in Angular 16.

5. **Update RxJS Code**: If you encounter RxJS compatibility issues, make sure you're using RxJS 7 patterns.

## Known Issues and Solutions

### Angular Material

Angular Material 16 has some breaking changes:

- MDC-based components are now the default
- Legacy components are available under the `/legacy` import path

### Strict Mode Changes

Angular 16 enforces stricter type checking. You might need to:

- Add proper return types to functions
- Fix nullable property access
- Add proper typing to event handlers

### Build Configuration

- If your build fails, check the updated webpack configuration
- Review any custom builders or schematics

## Testing Your Upgrade

After completing the upgrade:

1. Run `yarn build-lib` to build the libraries
2. Run `yarn test` to run unit tests
3. Run the application with `yarn serve` to verify it works correctly
4. Check for console errors and warnings

## Rolling Back

If you encounter issues that can't be easily fixed:

1. Remove the `node_modules` directory
2. Restore from the backup that was automatically created
3. Run `yarn install`

## Additional Resources

- [Angular Update Guide](https://update.angular.io/?v=15.0-16.0)
- [NX Migration Guide](https://nx.dev/using-nx/updating-nx)
- [Angular 16 Release Notes](https://blog.angular.io/angular-v16-is-here-4d7a28ec680d)
