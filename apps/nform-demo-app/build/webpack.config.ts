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

      return {
        NFORM_CONTENT_MAPPING_FILE: JSON.stringify(NFORM_CONTENT_MAPPING_FILE),
        ANGULAR_VERSION: JSON.stringify(angular.version),
        CDK_VERSION: JSON.stringify(cdk.version),
        NFORM_VERSION: JSON.stringify(nform.version),
        BUILD_VERSION: JSON.stringify(gitInfo.latest ? gitInfo.latest.short_hash : 'dev-build'),
        CONTENT_SERVER_URL: JSON.stringify(CONTENT_SERVER_URL)
      };
    };

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

    webpackConfig.plugins.push(new SsrAndSeoWebpackPlugin({
      ssrPagesFilename: 'ssr-pages.json',
      sitemap: {
        basePath: 'https://shlomiassaf.github.io/nform',
      },
    }));

    webpackConfig.plugins.push(new MarkdownAppSearchWebpackPlugin({}));


    webpackConfig.plugins.push(new MarkdownCodeExamplesWebpackPlugin({
      context: appRoot,
      docsPath: './content/**/*.ts',
    }));

    // Use only AsyncDefinePlugin to avoid conflicting DefinePlugin values


    // Add the WebpackConstantsPlugin for file generation only (without DefinePlugin)
    webpackConfig.plugins.push(new WebpackConstantsPlugin({ createDefinePlugin: false }));

    const definePlugin = new AsyncDefinePlugin(fn);
    webpackConfig.plugins.push(definePlugin);
  } catch (error) {
    console.error('Error adding content plugins:', error.message);
  }

  const angular = require('@angular/core/package.json');
  const cdk = require('@angular/cdk/package.json');


  // Fix for ENOTDIR error - use a direct require without Path.join
  const nformPackagePath = require.resolve('libs/nform/package.json');

  const nform = require(nformPackagePath);


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

module.exports = updateWebpackConfig;