import { ExecutorContext } from '@nx/devkit';
import { execSync } from 'child_process';
import * as path from 'path';
import * as fs from 'fs';

/**
 * Custom executor to wrap ng-packagr-lite and apply custom transformations
 */
export async function customBuildExecutor(options: any, context: ExecutorContext) {
  console.log('Initializing Webpack configuration...');
  
  // Get the original executor
  const { executorName } = context.target;
  const [collection, executor] = executorName.split(':');
  
  // Print the build information
  console.log(`Building ${context.projectName} using ${collection}:${executor}`);
  
  // Run the original executor through the Nx CLI
  // This is a workaround to use our console.log before the actual build starts
  const projectName = context.projectName;
  const configName = context.configurationName || 'production';
  
  try {
    const result = execSync(
      `npx nx run ${projectName}:build:${configName} --skip-nx-cache`,
      { stdio: 'inherit' }
    );
    return { success: true };
  } catch (error) {
    console.error('Build failed:', error);
    return { success: false };
  }
}
