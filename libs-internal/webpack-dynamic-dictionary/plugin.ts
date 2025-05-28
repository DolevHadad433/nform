import * as webpack from 'webpack';
import * as path from 'path';
import * as fs from 'fs';
export interface DynamicExportedObject { }; //tslint:disable-line

const pluginName = 'pebula-dynamic-dictionary-webpack-plugin';
const store = new WeakMap<webpack.Compiler, PebulaDynamicDictionaryWebpackPlugin>();

class LazySource {

  private metadata: DynamicExportedObject = {} as any;

  update<T extends keyof DynamicExportedObject>(key: T, value?: DynamicExportedObject[T]): void {
    if (value === undefined) {
      console.log(`[LazySource] Deleting key '${String(key)}'`);
      delete this.metadata[key];
    } else {
      console.log(`[LazySource] Setting key '${String(key)}' = '${value}'`);
      this.metadata[key] = value;
    }
  }

  toSource() {
    return new webpack.sources.CachedSource(() => {
      return new webpack.sources.RawSource(JSON.stringify(this.metadata));
    })

  }
}


/**
 * A simple plugin that just allows to expose a dynamic JSON object which can be live edited until main compilation emits.
 */
export class PebulaDynamicDictionaryWebpackPlugin {

  private lazySource = new LazySource();

  constructor(private readonly writePath: string) { }

  static find(compiler: webpack.Compiler): Pick<PebulaDynamicDictionaryWebpackPlugin, 'update'> | undefined {
    return store.get(compiler);
  }

  apply(compiler: webpack.Compiler): void {
    store.set(compiler, this);
    compiler.hooks.thisCompilation.tap(pluginName, compilation => {
      // Use processAssets hook with OPTIMIZE stage to ensure all other plugins have finished
      compilation.hooks.processAssets.tap(
        {
          name: pluginName,
          stage: webpack.Compilation.PROCESS_ASSETS_STAGE_OPTIMIZE,
        },
        () => {
          const contentJson = JSON.stringify(this.lazySource.toSource().source());
          const metadata = JSON.parse(contentJson);
          console.log(`[${pluginName}] Emitting dynamic dictionary with:`, JSON.stringify(metadata, null, 2));

          // Emit to webpack assets
          compilation.emitAsset(this.writePath, this.lazySource.toSource());

          // Also update source files that get copied by Angular assets
          try {
            const sourceFilePath = path.resolve(compiler.context, 'apps/nform-demo-app/src/nform-content-mapping.json');
            const toolsFilePath = path.resolve(compiler.context, 'tools/dist/nform-content-mapping.json');

            // Only update with the core mappings (not all the extra entries)
            const coreMapping = {
              markdownPages: metadata.markdownPages,
              markdownCodeExamples: metadata.markdownCodeExamples,
              searchContent: metadata.searchContent
            };
            const coreContent = JSON.stringify(coreMapping, null, 2);

            if (fs.existsSync(sourceFilePath)) {
              fs.writeFileSync(sourceFilePath, coreContent);
              console.log(`[${pluginName}] Updated source file: ${sourceFilePath}`);
            }

            if (fs.existsSync(path.dirname(toolsFilePath))) {
              fs.writeFileSync(toolsFilePath, coreContent);
              console.log(`[${pluginName}] Updated tools file: ${toolsFilePath}`);
            }
          } catch (error) {
            console.warn(`[${pluginName}] Warning: Could not update source files:`, error.message);
          }
        }
      );
    });
  }

  update<T extends keyof DynamicExportedObject>(key: T, value?: DynamicExportedObject[T]): void {
    console.log(`[${pluginName}] Updating key '${String(key)}' with value:`, value);
    this.lazySource.update(key, value);
  }
}
