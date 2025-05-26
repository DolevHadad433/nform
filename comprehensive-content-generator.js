/**
 * Comprehensive content file generator for nForm
 * This script reads the pages.json file to identify all content files,
 * then generates rich content for all of them with proper directory structure.
 */
const fs = require('fs');
const path = require('path');

// Configuration
const DIST_DIR = path.join(__dirname, 'dist');
const CONTENT_DIR = path.join(DIST_DIR, 'md-content');
const PAGES_FILE = path.join(DIST_DIR, 'md-content/pages.json');
const SRC_PAGES_FILE = path.join(__dirname, 'apps/nform-demo-app/src/md-content/pages.json');
const MAPPING_FILE_PATH = path.join(DIST_DIR, 'nform-content-mapping.json');

// Real content templates
const realContentTemplates = {
    'root': {
        id: "/",
        title: "Home",
        contents: "<div pbl-app-content-chunk=\"pbl-home-page-app-content-chunk\"></div>\n<br>\n<br>\n<br>\n<br>\n<br>"
    },
    'home': {
        id: "home",
        title: "Home",
        contents: "<div pbl-app-content-chunk=\"pbl-home-page-app-content-chunk\"></div>\n<h1>Welcome to NForm</h1>\n<p>A modern Angular Forms library with advanced features.</p>"
    },
    'quick-start': {
        id: "quick-start",
        title: "Quick Start",
        contents: "<div pbl-app-content-chunk=\"pbl-quick-start-app-content-chunk\"></div>\n<h1>Quick Start Guide</h1>\n<p>This is the official quick start guide for nForm.</p>"
    },
    'getting-started': {
        id: "getting-started",
        title: "Getting Started",
        contents: "<div pbl-app-content-chunk=\"pbl-getting-started-app-content-chunk\"></div>\n<h1>Getting Started with NForm</h1>\n<p>Learn how to set up your environment and create your first form.</p>"
    },
    'guide': {
        id: "guide",
        title: "Guide",
        contents: "<div pbl-app-content-chunk=\"pbl-guide-app-content-chunk\"></div>\n<h1>NForm Guide</h1>\n<p>Comprehensive guide to using NForm in your applications.</p>"
    },
    'guide/introduction': {
        id: "guide/introduction",
        title: "Guide Introduction",
        contents: "<h1 id=\"guide-how-to\"><a href=\"#guide-how-to\" aria-hidden><span class=\"icon icon-link\"></span></a>Guide: How to</h1>\n<h2 id=\"the-dashboard\"><a href=\"#the-dashboard\" aria-hidden><span class=\"icon icon-link\"></span></a>The Dashboard</h2>\n<p>This guide contains a lot of live form example, each example contains a\nsingle <code class=\"language-text\">pbl-nform</code> component wrapped within a <strong>dashboard</strong>.</p>\n<p>The <strong>dashboard</strong> provides tools to interact with the form, inspect state and access to the source code. </p>\n<div pbl-example-view=\"pbl-guide-intro-example\"></div>\n<p>Before we start rocking let's review the environment you're about to use.<br>\nThe examples in this tutorial are all real time angular code, running\nin your browser.<br>\nEach example comes with a dashboard that provides tools to inspect and\ninteract with the example, it's internal form/s and library instances.  </p>\n<p>The dashboard is the top panel, above the form showcased in the example.</p>\n<p><strong>You've already seen the dashboard, it right above...</strong></p>\n<p>Let's review what we can do with the dashboard:</p>\n<h3 id=\"real-time-form-status-indicator-led\"><a href=\"#real-time-form-status-indicator-led\" aria-hidden><span class=\"icon icon-link\"></span></a>Real time form status indicator LED</h3>\n<p>The LED is located at the top left.</p>\n<div pbl-app-content-chunk=\"pbl-led-legend-chunk\"></div>\n<h3 id=\"source-code-view\"><a href=\"#source-code-view\" aria-hidden><span class=\"icon icon-link\"></span></a>Source code view</h3>\n<p>The source code view can be toggled by the <strong>&#x3C; ></strong> button located in\nthe left section of the dashboard.  </p>\n<p>The source code view replace the form view, toggle it to see the form again.  </p>\n<p>An example comes with a complete source code for the component/s, template/s,\nstyle/s, model/s and any other code used by it.</p>\n<h3 id=\"form--model-interaction-menu\"><a href=\"#form--model-interaction-menu\" aria-hidden><span class=\"icon icon-link\"></span></a>Form / Model interaction menu</h3>\n<p>Next to the source code button you will find the interaction menu.<br>\nIn the menu you will find some tools to help you interact with the\nexample and inspect the current state:</p>\n<ul>\n<li>\n<p><strong>JSON View</strong>\nToggle's (show/hide) real time JSON view of the model or the form.<br>\nAppears in the <strong>right panel</strong> (we will get to panels in a bit)</p>\n</li>\n<li>\n<p><strong>Sync Form</strong>\nSync the form, this operation will updates the form values and validity status.<br>\nIt just calls <code class=\"language-text\">updateValueAndValidity()</code> on the form.</p>\n</li>\n<li>\n<p><strong>Commit</strong>\nTakes the current form and commits it to the model.</p>\n</li>\n</ul>\n"
    },
    'guide/basics': {
        id: "guide/basics",
        title: "Basics",
        contents: "<h1>NForm Basics</h1>\n<p>Basic usage and concepts for NForm.</p>\n<div pbl-example-view=\"pbl-nform-basics-example\"></div>"
    },
    'guide/basics/nform-basics': {
        id: "guide/basics/nform-basics",
        title: "nForm Basics",
        contents: "<h1>nForm Basics</h1>\n<p>Learn the basics of using NForm in your Angular applications.</p>\n<div pbl-example-view=\"pbl-nform-basics-example\"></div>"
    },
    'guide/basics/disable': {
        id: "guide/basics/disable",
        title: "Disable",
        contents: "<h1>Disabling Controls</h1>\n<p>Learn how to disable controls in NForm.</p>\n<div pbl-example-view=\"pbl-disable-example\"></div>"
    },
    'guide/basics/form-layout': {
        id: "guide/basics/form-layout",
        title: "Form Layout",
        contents: "<h1>Form Layout</h1>\n<p>Learn how to customize the layout of your forms with NForm.</p>\n<div pbl-example-view=\"pbl-vertical-form-layout-example\"></div>"
    },
    'guide/basics/form-layout-pinning': {
        id: "guide/basics/form-layout-pinning",
        title: "Form Layout Pinning",
        contents: "<h1>Form Layout Pinning</h1>\n<p>Learn how to pin specific elements in your form layout.</p>\n<div pbl-example-view=\"pbl-form-layout-pinning-example\"></div>"
    },
    'guide/basics/hide-or-filter-controls': {
        id: "guide/basics/hide-or-filter-controls",
        title: "Hide / Filter Controls",
        contents: "<h1>Hide and Filter Controls</h1>\n<p>Learn how to hide or filter controls in your NForm forms.</p>\n<div pbl-example-view=\"pbl-hide-filter-controls-example\"></div>"
    },
    'guide/basics/hot-binding': {
        id: "guide/basics/hot-binding",
        title: "Hot Binding",
        contents: "<h1>Hot Binding</h1>\n<p>Learn how to use hot binding in NForm for real-time updates.</p>\n<div pbl-example-view=\"pbl-hot-binding-example\"></div>"
    },
    'guide/basics/validation': {
        id: "guide/basics/validation",
        title: "Validation",
        contents: "<h1>Form Validation</h1>\n<p>Learn how to implement validation in your NForm forms.</p>\n<div pbl-example-view=\"pbl-validation-example\"></div>"
    },
    'guide/basics/model-form-sync': {
        id: "guide/basics/model-form-sync",
        title: "Model <-> Form Sync",
        contents: "<h1>Model and Form Synchronization</h1>\n<p>Learn how to keep your model and form in sync with NForm.</p>\n<div pbl-example-view=\"pbl-model-form-sync-example\"></div>"
    },
    'guide/basics/template-overrides': {
        id: "guide/basics/template-overrides",
        title: "Template Overrides",
        contents: "<h1>Template Overrides</h1>\n<p>Learn how to override default templates in NForm.</p>\n<div pbl-example-view=\"pbl-template-overrides-example\"></div>"
    },
    'guide/basics/form-splitting': {
        id: "guide/basics/form-splitting",
        title: "Form Splitting",
        contents: "<h1>Form Splitting</h1>\n<p>Learn how to split forms into multiple sections with NForm.</p>\n<div pbl-example-view=\"pbl-form-splitting-example\"></div>"
    },
    'guide/basics/advanced-controls': {
        id: "guide/basics/advanced-controls",
        title: "Advanced Controls",
        contents: "<h1>Advanced Controls</h1>\n<p>Learn how to use advanced controls in NForm.</p>\n<div pbl-example-view=\"pbl-advanced-controls-example\"></div>"
    },
    'guide/events': {
        id: "guide/events",
        title: "Events",
        contents: "<h1>Events in NForm</h1>\n<p>Learn about the event system in NForm.</p>\n<div pbl-example-view=\"pbl-value-changes-example\"></div>"
    },
    'guide/events/before-render': {
        id: "guide/events/before-render",
        title: "Before Render",
        contents: "<h1>Before Render Event</h1>\n<p>Learn how to use the before render event in NForm.</p>\n<div pbl-example-view=\"pbl-before-render-example\"></div>"
    },
    'guide/events/render-state': {
        id: "guide/events/render-state",
        title: "Render State",
        contents: "<h1>Render State Events</h1>\n<p>Learn how to work with render state events in NForm.</p>\n<div pbl-example-view=\"pbl-render-state-example\"></div>"
    },
    'guide/events/field-sync-redraw': {
        id: "guide/events/field-sync-redraw",
        title: "Field Sync Redraw",
        contents: "<h1>Field Sync and Redraw Events</h1>\n<p>Learn about field synchronization and redraw events in NForm.</p>\n<div pbl-example-view=\"pbl-field-sync-redraw-example\"></div>"
    },
    'guide/events/value-changes': {
        id: "guide/events/value-changes",
        title: "Value Changes",
        contents: "<h1>Value Changes Events</h1>\n<p>Learn how to handle value change events in NForm.</p>\n<div pbl-example-view=\"pbl-value-changes-example\"></div>"
    },
    'guide/advanced-modeling': {
        id: "guide/advanced-modeling",
        title: "Advanced Modeling",
        contents: "<h1>Advanced Modeling</h1>\n<p>Learn advanced modeling techniques in NForm.</p>\n<div pbl-example-view=\"pbl-advanced-modeling-example\"></div>"
    },
    'guide/advanced-modeling/controlling-nform': {
        id: "guide/advanced-modeling/controlling-nform",
        title: "Controlling Nform",
        contents: "<h1>Controlling NForm</h1>\n<p>Learn how to control NForm programmatically.</p>\n<div pbl-example-view=\"pbl-controlling-nform-example\"></div>"
    },
    'guide/advanced-modeling/complex-data-structures': {
        id: "guide/advanced-modeling/complex-data-structures",
        title: "Complex Data Structures",
        contents: "<h1>Complex Data Structures</h1>\n<p>Learn how to handle complex data structures in NForm.</p>\n<div pbl-example-view=\"pbl-complex-data-structures-example\"></div>"
    },
    'guide/advanced-modeling/child-forms': {
        id: "guide/advanced-modeling/child-forms",
        title: "Nested Forms: Child Forms",
        contents: "<h1>Child Forms</h1>\n<p>Learn how to use child forms in NForm.</p>\n<div pbl-example-view=\"pbl-child-forms-example\"></div>"
    },
    'guide/advanced-modeling/flattening': {
        id: "guide/advanced-modeling/flattening",
        title: "Nested Forms: Flattening",
        contents: "<h1>Form Flattening</h1>\n<p>Learn about form flattening techniques in NForm.</p>\n<div pbl-example-view=\"pbl-flattening-example\"></div>"
    },
    'guide/advanced-modeling/arrays': {
        id: "guide/advanced-modeling/arrays",
        title: "Arrays",
        contents: "<h1>Working with Arrays</h1>\n<p>Learn how to handle array data structures in NForm.</p>\n<div pbl-example-view=\"pbl-arrays-example\"></div>"
    },
    'guide/layout/the-renderer': {
        id: "guide/layout/the-renderer",
        title: "The Renderer",
        contents: "<h1>The Renderer</h1>\n<p>Learn about the renderer system in NForm.</p>\n<div pbl-example-view=\"pbl-the-renderer-example\"></div>"
    },
    'advanced-usage': {
        id: "advanced-usage",
        title: "Advanced Usage",
        contents: "<div pbl-app-content-chunk=\"pbl-advanced-usage-app-content-chunk\"></div>\n<h1>Advanced Usage</h1>\n<p>Learn advanced techniques and patterns for using NForm.</p>\n<br>\n<br>"
    },
    // Default template for any page not explicitly defined
    'default': {
        title: "Generated Content",
        contents: "<h1>{{title}}</h1>\n<p>Content for {{id}}.</p>"
    }
};

// Ensure directories exist
if (!fs.existsSync(DIST_DIR)) {
    fs.mkdirSync(DIST_DIR, { recursive: true });
}

if (!fs.existsSync(CONTENT_DIR)) {
    fs.mkdirSync(CONTENT_DIR, { recursive: true });
}

// Create or load content mapping
let mapping = {};
if (fs.existsSync(MAPPING_FILE_PATH)) {
    try {
        mapping = JSON.parse(fs.readFileSync(MAPPING_FILE_PATH, 'utf8'));
        console.log('Loaded existing content mapping');
    } catch (error) {
        console.error('Error parsing existing mapping file:', error.message);
        console.log('Creating new mapping file');
    }
}

// Create content for a page
function createContentFile(contentId, contentPath, fileId) {
    // Generate content based on template or default
    let contentTemplate = realContentTemplates[contentId] || null;

    if (!contentTemplate) {
        contentTemplate = JSON.parse(JSON.stringify(realContentTemplates.default));
        contentTemplate.id = contentId;

        // Extract title from the path (use the last part of the path)
        let title = contentId.split('/').pop() || contentId;
        title = title.charAt(0).toUpperCase() + title.slice(1).replace(/-/g, ' ');
        contentTemplate.title = title;

        // Format the content with title and ID
        contentTemplate.contents = contentTemplate.contents
            .replace('{{title}}', title)
            .replace('{{id}}', contentId)
            .replace('{{id-slug}}', contentId.replace(/\//g, '-'));
    }

    // Make sure the content has an ID field
    if (!contentTemplate.id) {
        contentTemplate.id = contentId;
    }

    // Create the standard content file in md-content directory
    const contentFilePath = path.join(CONTENT_DIR, `${contentId}.json`);

    // Ensure parent directory exists
    fs.mkdirSync(path.dirname(contentFilePath), { recursive: true });

    // Write the content file
    fs.writeFileSync(contentFilePath, JSON.stringify(contentTemplate, null, 2));
    console.log(`Created standard content file: ${contentFilePath}`);

    // Create the content in the special directory structure with ID
    if (contentPath && fileId) {
        // Parse the content path to extract the directory structure
        let dirPath = contentPath.substring(0, contentPath.lastIndexOf('/'));
        const targetDir = path.join(DIST_DIR, dirPath);

        // Create the directory structure
        fs.mkdirSync(targetDir, { recursive: true });

        // Create the content file
        const targetFile = path.join(DIST_DIR, contentPath);
        fs.writeFileSync(targetFile, JSON.stringify(contentTemplate, null, 2));
        console.log(`Created specific content file: ${targetFile}`);

        // Update mapping
        const contentPathKey = contentPath.replace('.json', '').replace('/', '');
        mapping[contentPathKey] = `md-content/${contentId}.json`;
        console.log(`Added mapping: ${contentPathKey} -> md-content/${contentId}.json`);
    }

    // Create direct access version without directory structure
    const noPathKey = `md-content${contentId}`;
    const noPathFile = path.join(DIST_DIR, `${noPathKey}.json`);
    fs.writeFileSync(noPathFile, JSON.stringify(contentTemplate, null, 2));
    console.log(`Created direct access file: ${noPathFile}`);

    // Update mapping for direct access
    mapping[noPathKey] = `md-content/${contentId}.json`;
    console.log(`Added mapping: ${noPathKey} -> md-content/${contentId}.json`);

    return contentTemplate;
}

// Main function to process pages
function processPages() {
    console.log('Starting comprehensive content generation...');

    // Load pages.json - try first from dist, then from src if not available
    let pagesData;
    if (fs.existsSync(PAGES_FILE)) {
        pagesData = JSON.parse(fs.readFileSync(PAGES_FILE, 'utf8'));
    } else if (fs.existsSync(SRC_PAGES_FILE)) {
        pagesData = JSON.parse(fs.readFileSync(SRC_PAGES_FILE, 'utf8'));

        // Create the pages.json file in dist/md-content
        fs.mkdirSync(path.dirname(PAGES_FILE), { recursive: true });
        fs.writeFileSync(PAGES_FILE, JSON.stringify(pagesData, null, 2));
        console.log(`Created pages.json in dist/md-content from src`);
    } else {
        console.error('Error: pages.json not found in dist or src');
        process.exit(1);
    }

    // Process all entries in entryData
    console.log('Processing content files from pages.json entryData...');
    for (const [contentId, contentPath] of Object.entries(pagesData.entryData)) {
        // Extract fileId from the contentPath
        let fileId = null;
        const matches = contentPath.match(/([0-9a-f]+)\.json$/);
        if (matches && matches[1]) {
            fileId = matches[1];
        }

        createContentFile(contentId, contentPath, fileId);
    }

    // Handle special cases that might not be in entryData
    console.log('Processing special cases...');
    createContentFile('root', 'md-contentroot.json', null);

    // Save the updated mapping
    fs.writeFileSync(MAPPING_FILE_PATH, JSON.stringify(mapping, null, 2));
    console.log(`Updated mapping file saved to ${MAPPING_FILE_PATH}`);

    console.log('Content generation completed successfully!');
}

// Run the main function
processPages();
