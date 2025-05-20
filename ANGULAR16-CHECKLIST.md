# Angular 16 Post-Upgrade Checklist

Use this checklist after running the upgrade scripts to ensure your project is fully compatible with Angular 16 and NX 16.

## Build Process

- [ ] Libraries build successfully with `yarn build-lib`
- [ ] Application builds successfully
- [ ] Server-side rendering works (if applicable)
- [ ] All webpack configurations are working

## Type Checking

- [ ] No TypeScript errors in the codebase
- [ ] All component inputs/outputs are properly typed
- [ ] Event handlers have proper typing

## Runtime Checks

- [ ] Application runs without console errors
- [ ] All major features are working
- [ ] Forms and validation are working
- [ ] Routing is working correctly
- [ ] Lazy loading modules work

## Angular Material

- [ ] Material components display correctly
- [ ] No legacy import paths are used (unless intended)
- [ ] Theming is working correctly

## Performance

- [ ] Bundle sizes are reasonable (check budgets)
- [ ] Initial load time is acceptable
- [ ] No memory leaks during usage

## Testing

- [ ] Unit tests pass
- [ ] E2E tests pass
- [ ] Test coverage is maintained

## Updated APIs

- [ ] Check deprecated `HttpClient` methods and update
- [ ] Update any usage of deprecated Angular APIs
- [ ] Update any usage of deprecated RxJS operators
- [ ] Check for `ViewChild` queries that might need static flag

## NX-specific

- [ ] NX commands work correctly
- [ ] Project structure is recognized by NX
- [ ] All paths have been updated from `@nrwl/*` to `@nx/*`
- [ ] NX workspace commands like `affected` work correctly

## CI/CD

- [ ] CI pipeline completes successfully
- [ ] Deployment process works
- [ ] Environment-specific builds work

## Documentation

- [ ] Update documentation to reflect Angular 16 changes
- [ ] Update any version-specific information

## Cleanup

- [ ] Remove any temporary files created during upgrade
- [ ] Remove backup files once upgrade is verified
- [ ] Update version numbers in package.json
