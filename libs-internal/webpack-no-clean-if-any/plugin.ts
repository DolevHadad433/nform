import { SyncBailHook } from 'tapable';
import * as webpack from 'webpack';

const pluginName = 'pebula-no-clean-if-any-webpack-plugin';
const compilerHooksMap = new WeakMap<webpack.Compiler, PebulaNoCleanIfAnyWebpackPluginCompilerHooks>();

export interface PebulaNoCleanIfAnyWebpackPluginCompilerHooks {
  keep: SyncBailHook<string, boolean>;
}

export class PebulaNoCleanIfAnyWebpackPlugin {
  static getCompilationHooks(compiler: webpack.Compiler): PebulaNoCleanIfAnyWebpackPluginCompilerHooks {
    let hooks = compilerHooksMap.get(compiler);
    if (hooks === undefined) {
      hooks = {
        keep: new SyncBailHook(['keep']),
      };
      compilerHooksMap.set(compiler, hooks);
    }
    return hooks;
  }

  apply(compiler: webpack.Compiler & { watchMode?: boolean }): void {
    PebulaNoCleanIfAnyWebpackPlugin.getCompilationHooks(compiler).keep.intercept({
      register: (tapInfo) => {
        var fn = tapInfo.fn;
        tapInfo.fn = (...args: any[]) => {
          var result = fn(...args);
          if (result === true) return true;
          return undefined;
        };
        return tapInfo;
      },
    });

    compiler.hooks.compilation.tap(pluginName, (compilation) => {
      // Check if CleanPlugin hooks are available before trying to access them
      try {
        const cleanHooks = webpack.CleanPlugin.getCompilationHooks(compilation);
        if (cleanHooks && cleanHooks.keep) {
          cleanHooks.keep.tap(pluginName, (asset) =>
            PebulaNoCleanIfAnyWebpackPlugin.getCompilationHooks(compiler).keep.call(asset)
          );
        }
      } catch (error) {
        // If CleanPlugin is not available or the compilation is not ready, skip this hook
        compiler.getInfrastructureLogger(pluginName).debug('CleanPlugin hooks not available:', error.message);
      }
    });
  }
}
