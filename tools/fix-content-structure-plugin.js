/**
 * Webpack plugin to fix content structure in pages.json
 * This plugin intercepts the markdown pages webpack plugin output 
 * and ensures the correct structure is generated
 */
const webpack = require('webpack');
const path = require('path');
const fs = require('fs');

class FixContentStructurePlugin {
    constructor(options = {}) {
        // Default options
        this.options = Object.assign(
            {
                pagesJsonPath: 'md-content/pages.json',
                generateContentFiles: true,
            },
            options
        );
    }

    apply(compiler) {
        // Hook into the emit phase
        compiler.hooks.emit.tapAsync('FixContentStructurePlugin', (compilation, callback) => {
            // Find the pages.json asset
            const pagesJsonAsset = compilation.assets[this.options.pagesJsonPath];

            if (pagesJsonAsset) {
                console.log('Found pages.json asset, fixing content structure...');

                try {
                    // Get the current pages.json content
                    const pagesJsonContent = pagesJsonAsset.source();
                    const pagesJson = JSON.parse(pagesJsonContent);

                    // Fix the structure
                    const fixedPagesJson = this.fixContentStructure(pagesJson);

                    // Replace the asset with the fixed version
                    compilation.assets[this.options.pagesJsonPath] = {
                        source: () => JSON.stringify(fixedPagesJson, null, 2),
                        size: () => JSON.stringify(fixedPagesJson, null, 2).length
                    };

                    console.log('Successfully fixed pages.json structure');

                    // Generate content files if needed
                    if (this.options.generateContentFiles) {
                        this.generateContentFiles(fixedPagesJson, compilation);
                    }
                } catch (error) {
                    console.error('Error fixing pages.json content structure:', error);
                }
            } else {
                console.warn('Could not find pages.json asset at', this.options.pagesJsonPath);
            }

            callback();
        });
    }

    fixContentStructure(pagesJson) {
        // Ensure we have the correct structure
        const fixedPagesJson = {
            entries: {},
            entryData: {}
        };

        // Fix the entries structure
        if (pagesJson.entries) {
            // Home page should have path "/"
            if (pagesJson.entries.home) {
                fixedPagesJson.entries["/"] = {
                    ...pagesJson.entries.home,
                    title: "Home",
                    path: "/",
                    type: "index"
                };
            } else {
                fixedPagesJson.entries["/"] = {
                    title: "Home",
                    path: "/",
                    type: "index"
                };
            }

            // Fix the guide section to use the correct structure
            if (pagesJson.entries.guide) {
                fixedPagesJson.entries.guide = {
                    ...pagesJson.entries.guide,
                    title: "Guide",
                    path: "guide",
                    type: "topMenuSection",
                    tooltip: "How-to Guide",
                    searchGroup: "guide"
                };

                // Ensure children have the correct structure
                if (pagesJson.entries.guide.children) {
                    fixedPagesJson.entries.guide.children = this.fixChildren(pagesJson.entries.guide.children);
                }
            }

            // Copy any other top-level entries
            Object.keys(pagesJson.entries).forEach(key => {
                if (key !== 'home' && key !== 'guide' && key !== '/') {
                    fixedPagesJson.entries[key] = {
                        ...pagesJson.entries[key],
                        type: pagesJson.entries[key].type || "topMenuSection",
                        tooltip: pagesJson.entries[key].tooltip || pagesJson.entries[key].title,
                        searchGroup: pagesJson.entries[key].searchGroup || key
                    };

                    // Fix children for this section
                    if (pagesJson.entries[key].children) {
                        fixedPagesJson.entries[key].children = this.fixChildren(pagesJson.entries[key].children);
                    }
                }
            });
        }

        // Fix the entryData structure - ensure all paths are correct
        if (pagesJson.entryData) {
            Object.keys(pagesJson.entryData).forEach(key => {
                const path = pagesJson.entryData[key];

                // Ensure path uses correct format
                let fixedPath = path;

                // If the path doesn't include a file extension, add .json
                if (!fixedPath.endsWith('.json')) {
                    fixedPath = `${fixedPath}.json`;
                }

                // Ensure path uses the correct format for md-content
                if (!fixedPath.startsWith('md-content/')) {
                    fixedPath = `md-content/${fixedPath}`;
                }

                fixedPagesJson.entryData[key] = fixedPath;
            });
        }

        return fixedPagesJson;
    }

    fixChildren(children) {
        if (!Array.isArray(children)) {
            return children;
        }

        return children.map(child => {
            const fixedChild = {
                ...child,
                tooltip: child.tooltip || child.title
            };

            if (child.children) {
                fixedChild.children = this.fixChildren(child.children);
            }

            return fixedChild;
        });
    }

    generateContentFiles(pagesJson, compilation) {
        console.log('Generating content files for entryData...');

        // Process each file in entryData
        Object.entries(pagesJson.entryData).forEach(([id, filePath]) => {
            // Skip if file already exists in compilation
            if (compilation.assets[filePath]) {
                console.log(`Content file already exists in compilation: ${filePath}`);
                return;
            }

            // Create content file
            const title = this.getPageTitle(id, pagesJson);
            const content = this.createContentTemplate(id, title);

            // Add to compilation assets
            compilation.assets[filePath] = {
                source: () => content,
                size: () => content.length
            };

            console.log(`Generated content file: ${filePath}`);
        });
    }

    getPageTitle(id, pagesJson) {
        // Find the page entry that matches this ID
        const searchForTitle = (entries) => {
            if (!entries) return null;

            for (const key in entries) {
                const entry = entries[key];

                // Check if this is the page we're looking for
                if (entry.path && entry.path.replace(/\//g, '-') === id) {
                    return entry.title;
                }

                // Check children recursively
                if (entry.children) {
                    const childTitle = this.searchTitleInChildren(entry.children, id);
                    if (childTitle) return childTitle;
                }
            }

            return null;
        };

        const title = searchForTitle(pagesJson.entries) || `Content for ${id}`;
        return title;
    }

    searchTitleInChildren(children, id) {
        if (!Array.isArray(children)) return null;

        for (const child of children) {
            // Check if this child is the page we're looking for
            if (child.path && child.path.replace(/\//g, '-') === id) {
                return child.title;
            }

            // Check this child's children
            if (child.children) {
                const foundTitle = this.searchTitleInChildren(child.children, id);
                if (foundTitle) return foundTitle;
            }
        }

        return null;
    }

    createContentTemplate(id, title) {
        return JSON.stringify({
            id,
            title,
            contents: `# ${title}\n\nThis is content for ${id}.`
        }, null, 2);
    }
}

module.exports = FixContentStructurePlugin;
