/**
 * Webpack plugin to copy content mapping files to the output directory
 * This ensures the content mapping files are always available in the correct location
 */
const path = require('path');
const fs = require('fs');
const { promisify } = require('util');
const copyFile = promisify(fs.copyFile);
const mkdir = promisify(fs.mkdir);

class ContentMappingFilesPlugin {
  constructor(options = {}) {
    this.options = Object.assign(
      {
        mappingFile: 'nform-content-mapping.json',
        contentDir: 'md-content',
        createIfMissing: true,
      },
      options
    );
  }

  apply(compiler) {
    const pluginName = 'ContentMappingFilesPlugin';
    
    // Hook into the emit phase of compilation
    compiler.hooks.emit.tapAsync(pluginName, async (compilation, callback) => {
      try {
        console.log(`[${pluginName}] Ensuring content mapping files are available...`);
        
        const outputPath = compilation.outputOptions.path;
        const distPath = path.resolve(__dirname, './dist');
        
        // Create mapping file if it doesn't exist
        if (this.options.createIfMissing) {
          await this.ensureContentMappingExists(distPath);
        }
        
        // Copy mapping file to output directory
        const mappingFilePath = path.join(distPath, this.options.mappingFile);
        if (fs.existsSync(mappingFilePath)) {
          // Add the mapping file to webpack's output assets
          const mappingContent = fs.readFileSync(mappingFilePath);
          compilation.assets[this.options.mappingFile] = {
            source: () => mappingContent,
            size: () => mappingContent.length
          };
          
          // Copy content directory files if they exist
          const contentDirPath = path.join(distPath, this.options.contentDir);
          if (fs.existsSync(contentDirPath)) {
            const contentFiles = fs.readdirSync(contentDirPath);
            for (const file of contentFiles) {
              if (file.endsWith('.json')) {
                const contentPath = path.join(contentDirPath, file);
                const outputContentPath = path.join(this.options.contentDir, file);
                const content = fs.readFileSync(contentPath);
                compilation.assets[outputContentPath] = {
                  source: () => content,
                  size: () => content.length
                };
              }
            }
          }
          
          console.log(`[${pluginName}] Content mapping files added to webpack output`);
        } else {
          console.warn(`[${pluginName}] Warning: Mapping file not found at ${mappingFilePath}`);
        }
        
        callback();
      } catch (err) {
        console.error(`[${pluginName}] Error:`, err);
        callback();
      }
    });
  }
  
  async ensureContentMappingExists(distPath) {
    // Create dist directory if it doesn't exist
    if (!fs.existsSync(distPath)) {
      await mkdir(distPath, { recursive: true });
    }
    
    // Create md-content directory if it doesn't exist
    const contentDirPath = path.join(distPath, this.options.contentDir);
    if (!fs.existsSync(contentDirPath)) {
      await mkdir(contentDirPath, { recursive: true });
    }
    
    // Create mapping file if it doesn't exist
    const mappingFilePath = path.join(distPath, this.options.mappingFile);
    if (!fs.existsSync(mappingFilePath)) {
      const mappingContent = JSON.stringify({
        markdownPages: `${this.options.contentDir}/pages.json`,
        markdownCodeExamples: `${this.options.contentDir}/code-examples.json`,
        searchContent: `${this.options.contentDir}/search-content.json`
      }, null, 2);
      
      fs.writeFileSync(mappingFilePath, mappingContent);
      
      // Create empty content files if they don't exist
      const contentFiles = {
        'pages.json': '{"pages":[]}',
        'code-examples.json': '{"examples":[]}',
        'search-content.json': '{"content":[]}'
      };
      
      for (const [file, content] of Object.entries(contentFiles)) {
        const contentFilePath = path.join(contentDirPath, file);
        if (!fs.existsSync(contentFilePath)) {
          fs.writeFileSync(contentFilePath, content);
        }
      }
    }
  }
}

module.exports = ContentMappingFilesPlugin;
