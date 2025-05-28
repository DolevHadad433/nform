import * as Path from 'path';
import { Compiler, DefinePlugin, WebpackOptionsNormalized } from 'webpack';
import * as simplegit from 'simple-git/promise';

import { PebulaDynamicDictionaryWebpackPlugin } from '@pebula-internal/webpack-dynamic-dictionary';
import { PebulaNoCleanIfAnyWebpackPlugin } from '@pebula-internal/webpack-no-clean-if-any';
import { MarkdownPagesWebpackPlugin } from '@pebula-internal/webpack-markdown-pages';
import { SsrAndSeoWebpackPlugin } from '@pebula-internal/webpack-ssr-and-seo';
import { MarkdownAppSearchWebpackPlugin } from '@pebula-internal/webpack-markdown-app-search';
import { MarkdownCodeExamplesWebpackPlugin } from '@pebula-internal/webpack-markdown-code-examples';
import type { AngularWebpackPlugin as _AngularWebpackPlugin } from '@ngtools/webpack';
import * as remarkPlugins from './remark';

const appRoot = Path.resolve(__dirname, "..");

// ** CONFIG VALUES **
function applyLoaders(webpackConfig: WebpackOptionsNormalized) {
  // We have custom loaders, for webpack to be aware of them we tell it the directory the are in.
  // make sure that each folder behaves like a node module, that is it has an index file inside root or a package.json pointing to it.
  // the default lib generation of nx and angular/cli does not do that.
  if (!webpackConfig.resolveLoader.modules)
    webpackConfig.resolveLoader.modules = ["node_modules"];

  webpackConfig.resolveLoader.modules.push("libs-internal");

  // We push new loader rules to handle the scenarios
  // we also add a loader to handle markdown files.
  webpackConfig.module.rules.push(
    {
      test: [/\.html$/],
      use: ["html-loader"],
      resourceQuery: { not: [/\\?ngResource/] },
    },
  );
}


function updateWebpackConfig(webpackConfig: WebpackOptionsNormalized): WebpackOptionsNormalized {
  console.log('🎯 ELIRAN WEBPACK.JS EQUIVALENT - updateWebpackConfig() called! This proves webpack is executing.');

  applyLoaders(webpackConfig);

  try {
    // Find Angular plugins to disable direct template loading
    const angularPlugins = webpackConfig.plugins.filter(
      p => p.constructor.name === 'AngularWebpackPlugin'
    );

  } catch (error) {
    console.log('Error setting Angular plugin options:', error.message);
  }


  const remarkSlug = require('remark-slug')
  const remarkAutolinkHeadings = require('@rigor789/remark-autolink-headings');
  const remarkAttr = require('remark-attr')

  // const ContentMappingFilesPlugin = require("../../../tools/content-mapping-files-plugin");
  const ContentMappingPlugin = require("../../../tools/webpack/content-mapping-plugin");
  const WebpackConstantsPlugin = require("../../../tools/webpack-constants-plugin");

  const customBlockquotesOptions = {
    mapping: {
      'i>': 'info',
      'I>': 'info icon',
      'w>': 'warn',
      'W>': 'warn icon',
      'e>': 'error',
      'E>': 'error icon',
    }
  };

  // Get the value from environment variable or use default
  const NFORM_CONTENT_MAPPING_FILE = process.env.NFORM_CONTENT_MAPPING_FILE || 'nform-content-mapping.json';
  const CONTENT_SERVER_URL = process.env.CONTENT_SERVER_URL || 'http://localhost:4201';
  console.log('Using content mapping file:', NFORM_CONTENT_MAPPING_FILE);
  console.log('Using content server URL:', CONTENT_SERVER_URL);

  try {
    const fn = async () => {
      const format = {
        short_hash: '%h',
        hash: '%H',
        date: '%ai',
        message: '%s',
        refs: '%D',
        body: '%b',
        author_name: '%aN',
        author_email: '%ae'
      };


      const gitInfo = await simplegit().log({ n: "1", format });
      // Ensure NFORM_CONTENT_MAPPING_FILE is properly defined
      console.log('Setting NFORM_CONTENT_MAPPING_FILE in DefinePlugin to:', NFORM_CONTENT_MAPPING_FILE);
      console.log('Setting CONTENT_SERVER_URL in DefinePlugin to:', CONTENT_SERVER_URL);

      return {
        NFORM_CONTENT_MAPPING_FILE: JSON.stringify(NFORM_CONTENT_MAPPING_FILE),
        ANGULAR_VERSION: JSON.stringify(angular.version),
        CDK_VERSION: JSON.stringify(cdk.version),
        NFORM_VERSION: JSON.stringify(nform.version),
        BUILD_VERSION: JSON.stringify(gitInfo.latest ? gitInfo.latest.short_hash : 'dev-build'),
        CONTENT_SERVER_URL: JSON.stringify(CONTENT_SERVER_URL)
      };
    };

    // Add debug plugin to track webpack execution (equivalent to your console.log goal)
    webpackConfig.plugins.push(new WebpackExecutionDebugPlugin('eliran'));

    // Use only AsyncDefinePlugin to avoid conflicting DefinePlugin values
    const definePlugin = new AsyncDefinePlugin(fn);
    webpackConfig.plugins.push(definePlugin);

    // Add the WebpackConstantsPlugin for file generation only (without DefinePlugin)
    webpackConfig.plugins.push(new WebpackConstantsPlugin({ createDefinePlugin: false }));
    // Add plugins for content handling

    webpackConfig.plugins.push(new PebulaDynamicDictionaryWebpackPlugin(NFORM_CONTENT_MAPPING_FILE));

    webpackConfig.plugins.push(new PebulaNoCleanIfAnyWebpackPlugin());

    webpackConfig.plugins.push(new MarkdownPagesWebpackPlugin({
      context: appRoot,
      docsPath: '**/*.md',
      docsRoot: './content',
      outputAssetPathRoot: 'md-content',
      remarkPlugins: [
        remarkSlug,
        remarkAutolinkHeadings,
        [remarkAttr, { scope: 'permissive' }],
        remarkPlugins.gatsbyRemarkPrismJs(),
        [remarkPlugins.customBlockquotes, customBlockquotesOptions],
      ],
    }));

    webpackConfig.plugins.push(new MarkdownCodeExamplesWebpackPlugin({
      context: appRoot,
      docsPath: './content/**/*.ts',
    }));

    webpackConfig.plugins.push(new MarkdownAppSearchWebpackPlugin({}));

    webpackConfig.plugins.push(new SsrAndSeoWebpackPlugin({
      ssrPagesFilename: 'ssr-pages.json',
      sitemap: {
        basePath: 'https://shlomiassaf.github.io/nform',
      },
    }));

    // ContentMappingFilesPlugin disabled - PebulaDynamicDictionaryWebpackPlugin handles mapping generation
    // webpackConfig.plugins.push(new ContentMappingFilesPlugin());

    // ContentMappingPlugin disabled to avoid asset conflicts with PebulaDynamicDictionaryWebpackPlugin
    // The PebulaDynamicDictionaryWebpackPlugin handles the main mapping file emission
    // webpackConfig.plugins.push(new ContentMappingPlugin({
    //   outputDir: Path.resolve(__dirname, '../../../dist/browser'),
    //   targetFiles: [
    //     Path.resolve(__dirname, '../../../tools/content-map.core.ts'),
    //     Path.resolve(__dirname, '../../../apps/libs/shared-data/lib/search/content-map.service.ts')
    //   ],
    //   mappingFileName: NFORM_CONTENT_MAPPING_FILE
    // }));

  } catch (error) {
    console.error('Error adding content plugins:', error.message);
  }

  const angular = require('@angular/core/package.json');
  const cdk = require('@angular/cdk/package.json');


  // Fix for ENOTDIR error - use a direct require without Path.join
  const nformPackagePath = require.resolve('libs/nform/package.json');

  const nform = require(nformPackagePath);



  // webpackConfig.plugins.push(new debug.ProfilingPlugin({
  //     outputPath: Path.join(process.cwd(), 'webpack_profiling_events.json'),
  //   })
  // );

  // Add watchOptions to prevent infinite rebuild loops
  webpackConfig.watchOptions = {
    ...webpackConfig.watchOptions,
    ignored: [
      '**/node_modules/**',
      '**/dist/**',
      '**/.git/**',
      '**/coverage/**',
      '**/tmp/**',
      '**/.nx/**',
      '**/webpack-constants.json'
    ],
    poll: false,
    aggregateTimeout: 300
  };

  // Configure dev server to serve static files from dist directory
  const devServer = webpackConfig.devServer as any;
  if (!devServer || devServer === false) {
    webpackConfig.devServer = {};
  }

  const currentStatic = Array.isArray(devServer?.static)
    ? devServer.static
    : devServer?.static
      ? [devServer.static]
      : [];

  webpackConfig.devServer = {
    ...devServer,
    static: [
      ...currentStatic,
      {
        directory: Path.join(__dirname, '../../../dist'),
        publicPath: '/',
        watch: true
      }
    ],
    // Enable fallback for SPA routing
    historyApiFallback: {
      disableDotRule: true,
      rewrites: [
        // Don't fallback for files that should be served statically
        {
          from: /\.json$/, to: function (context: any) {
            return context.parsedUrl.pathname;
          }
        },
        {
          from: /\.js$/, to: function (context: any) {
            return context.parsedUrl.pathname;
          }
        },
        {
          from: /\.css$/, to: function (context: any) {
            return context.parsedUrl.pathname;
          }
        },
        // Fallback to index.html for all other routes
        { from: /./, to: '/index.html' }
      ]
    }
  };

  return webpackConfig;
}



export class AsyncDefinePlugin {

  constructor(private asyncDef: () => Promise<any>) {
    console.log('AsyncDefinePlugin', this);

  }

  apply(compiler: Compiler) {
    console.log('Applying AsyncDefinePlugin', this);
    let executeDefinePlugin = async () => {
      const definitions = await this.asyncDef();
      const definePlugin = new DefinePlugin(definitions);
      definePlugin.apply(compiler);
    };

    compiler.hooks.run.tapPromise('AsyncDefinePlugin', executeDefinePlugin);

    compiler.hooks.watchRun.tapPromise('AsyncDefinePlugin', async (compilation) => {
      if (executeDefinePlugin) {
        await executeDefinePlugin();
        executeDefinePlugin = undefined;
      }
    });
  }
}

// Add a debug plugin class to track webpack execution
class WebpackExecutionDebugPlugin {
  constructor(private identifier: string = 'eliran') {
    console.log(`🔧 [${this.identifier}] WebpackExecutionDebugPlugin initialized - webpack is being set up!`);
  }

  apply(compiler: Compiler) {
    const identifier = this.identifier;

    console.log(`🔥 [${identifier}] webpack.js EQUIVALENT - Webpack compilation is starting!`);

    compiler.hooks.environment.tap('WebpackExecutionDebugPlugin', () => {
      console.log(`🌍 [${identifier}] Webpack environment hook - webpack.js core is executing`);
    });

    compiler.hooks.afterEnvironment.tap('WebpackExecutionDebugPlugin', () => {
      console.log(`🎯 [${identifier}] Webpack after environment - webpack.js setup complete`);
    });

    compiler.hooks.beforeRun.tapAsync('WebpackExecutionDebugPlugin', (compiler, callback) => {
      console.log(`🚀 [${identifier}] Webpack before run - THIS IS YOUR console.log('eliran webpack.js') EQUIVALENT!`);
      callback();
    });

    compiler.hooks.run.tapAsync('WebpackExecutionDebugPlugin', (compiler, callback) => {
      console.log(`▶️ [${identifier}] Webpack run started - webpack.js is actively running!`);
      callback();
    });

    compiler.hooks.compilation.tap('WebpackExecutionDebugPlugin', (compilation) => {
      console.log(`📦 [${identifier}] Webpack compilation phase - webpack is processing your code!`);
    });
  }
}

module.exports = updateWebpackConfig;