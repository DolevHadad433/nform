![npm (scoped)](https://img.shields.io/npm/v/@pebula/nform?label=nform&style=flat-square)
![npm (scoped)](https://img.shields.io/npm/v/@pebula/nform-material?label=nform-material&style=flat-square)
![CircleCI](https://img.shields.io/circleci/build/github/shlomiassaf/nform/master?style=flat-square&token=abc123def456)
![GitHub](https://img.shields.io/github/license/shlomiassaf/nform?style=flat-square)

# N-FORM

---

For full documentation, walkthroughs and examples - [visit the official site](https://shlomiassaf.github.io/nform)

---

## Quick Start

- [Documentation site](https://shlomiassaf.github.io/nform) with code samples.
- [Starter @ GitHub](https://github.com/shlomiassaf/nform-material-starter)
- [Starter @ StackBlitz](https://stackblitz.com/edit/pebula-nform-starter?file=app%2Fapp.component.ts)

## Setup

```bash
yarn add @pebula/utils @pebula/nform @pebula/nform-material
```

## Development

### Building with Webpack Constants

If you encounter errors related to missing constants like `ANGULAR_VERSION` or `CDK_VERSION`, you can use our provided scripts:

```bash
# Fix webpack constants
./fix-webpack-constants.sh

# Build with constants properly defined
./build-with-constants.sh

# Test if constants are working
./test-webpack-constants.sh
```

For more information, see [Webpack Constants Fix](docs/WEBPACK_CONSTANTS_FIX.md).
