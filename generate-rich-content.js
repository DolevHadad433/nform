/**
 * Script to generate proper content files with the actual content instead of placeholders
 */
const fs = require('fs');
const path = require('path');

// Configuration
const DIST_DIR = path.join(__dirname, 'dist');
const CONTENT_DIR = path.join(DIST_DIR, 'md-content');
const MAPPING_FILE_PATH = path.join(DIST_DIR, 'nform-content-mapping.json');

// Real content templates for different file types
const realContentTemplates = {
    'root': {
        id: "/",
        title: "Home",
        contents: "<div pbl-app-content-chunk=\"pbl-home-page-app-content-chunk\"></div>\n<br>\n<br>\n<br>\n<br>\n<br>"
    },
    'home': {
        id: "home",
        title: "Home",
        contents: "<div pbl-app-content-chunk=\"pbl-home-page-app-content-chunk\"></div>\n<h1>Welcome to NForm</h1>\n<p>A modern Angular Forms library with advanced features.</p>\n<br>\n<br>"
    },
    'quick-start': {
        id: "quick-start",
        title: "Quick Start",
        contents: "<div pbl-app-content-chunk=\"pbl-quick-start-app-content-chunk\"></div>\n<h1>Quick Start Guide</h1>\n<p>This is the official quick start guide for nForm.</p>\n<br>\n<br>"
    },
    'getting-started': {
        id: "getting-started",
        title: "Getting Started",
        contents: "<div pbl-app-content-chunk=\"pbl-getting-started-app-content-chunk\"></div>\n<h1>Getting Started with NForm</h1>\n<p>Learn how to set up your environment and create your first form.</p>\n<br>\n<br>"
    },
    'guide': {
        id: "guide",
        title: "Guide",
        contents: "<div pbl-app-content-chunk=\"pbl-guide-app-content-chunk\"></div>\n<h1>NForm Guide</h1>\n<p>Comprehensive guide to using NForm in your applications.</p>\n<br>\n<br>"
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
    'guide/basics/disable-form': {
        id: "guide/basics/disable-form",
        title: "Disable Form",
        contents: "<h1>Disable Form</h1>\n<p>Learn how to disable an entire form in NForm.</p>\n<div pbl-example-view=\"pbl-disable-form-example\"></div>"
    },
    'guide/basics/form-layout': {
        id: "guide/basics/form-layout",
        title: "Form Layout",
        contents: "<h1>Form Layout</h1>\n<p>Learn how to customize the layout of your forms with NForm.</p>\n<div pbl-example-view=\"pbl-vertical-form-layout-example\"></div>"
    },
    'guide/basics/flex-form-layout': {
        id: "guide/basics/flex-form-layout",
        title: "Flex Form Layout",
        contents: "<h1>Flex Form Layout</h1>\n<p>Learn how to use flex layout for your forms.</p>\n<div pbl-example-view=\"pbl-flex-form-layout-example\"></div>"
    },
    'guide/basics/horizontal-form-layout': {
        id: "guide/basics/horizontal-form-layout",
        title: "Horizontal Form Layout",
        contents: "<h1>Horizontal Form Layout</h1>\n<p>Learn how to create horizontal form layouts.</p>\n<div pbl-example-view=\"pbl-horizontal-form-layout-example\"></div>"
    },
    'advanced-usage': {
        id: "advanced-usage",
        title: "Advanced Usage",
        contents: "<div pbl-app-content-chunk=\"pbl-advanced-usage-app-content-chunk\"></div>\n<h1>Advanced Usage</h1>\n<p>Learn advanced techniques and patterns for using NForm.</p>\n<br>\n<br>"
    },
    'guide/advanced-modeling/imperative': {
        id: "guide/advanced-modeling/imperative",
        title: "Imperative Forms",
        contents: "<h1>Imperative Forms</h1>\n<p>Learn how to create forms imperatively without decorators.</p>\n<div pbl-example-view=\"pbl-imperative-example\"></div>"
    },
    'guide/advanced-modeling/virtual-groups': {
        id: "guide/advanced-modeling/virtual-groups",
        title: "Virtual Groups",
        contents: "<h1>Virtual Groups</h1>\n<p>Learn how to work with virtual groups in NForm.</p>\n<div pbl-example-view=\"pbl-virtual-groups-example\"></div>"
    },
    'guide/advanced-modeling/virtual-groups-wizard': {
        id: "guide/advanced-modeling/virtual-groups-wizard",
        title: "Virtual Groups Wizard",
        contents: "<h1>Virtual Groups Wizard</h1>\n<p>Learn how to create wizards using virtual groups.</p>\n<div pbl-example-view=\"pbl-virtual-groups-wizard-example\"></div>"
    },
    // Add more templates as needed
    'default': {
        title: "Generated Content",
        html: "<h1>This content was generated dynamically</h1><p>This file was created to fix missing content issues.</p>"
    }
};

// Ensure directories exist
if (!fs.existsSync(DIST_DIR)) {
    fs.mkdirSync(DIST_DIR, { recursive: true });
}

if (!fs.existsSync(CONTENT_DIR)) {
    fs.mkdirSync(CONTENT_DIR, { recursive: true });
}

// Create content mapping
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

// Function to create or update a content file
function createContentFile(contentId, fileId = null) {
    // Determine the content to use
    const contentTemplate = realContentTemplates[contentId] || realContentTemplates.default;

    // If we don't have a template for this specific content, create one based on the default
    if (!realContentTemplates[contentId]) {
        contentTemplate.id = contentId;
        contentTemplate.title = contentId.charAt(0).toUpperCase() + contentId.slice(1).replace(/-/g, ' ');
    }

    // Create the file in md-content directory
    const filePath = path.join(CONTENT_DIR, `${contentId}.json`);
    fs.writeFileSync(filePath, JSON.stringify(contentTemplate, null, 2));
    console.log(`Created/updated content file: ${filePath}`);

    // Create a direct access version if fileId is provided
    if (fileId) {
        const directPath = path.join(DIST_DIR, `md-content${contentId}${fileId}.json`);
        fs.copyFileSync(filePath, directPath);
        console.log(`Created direct access file: ${directPath}`);

        // Update mapping
        mapping[`md-content${contentId}${fileId}`] = `md-content/${contentId}.json`;
        console.log(`Added mapping: md-content${contentId}${fileId} -> md-content/${contentId}.json`);
    }

    // Also create a direct access version without fileId
    const noIdPath = path.join(DIST_DIR, `md-content${contentId}.json`);
    fs.copyFileSync(filePath, noIdPath);
    console.log(`Created simplified direct access file: ${noIdPath}`);

    // Update mapping for the version without fileId
    mapping[`md-content${contentId}`] = `md-content/${contentId}.json`;
    console.log(`Added mapping: md-content${contentId} -> md-content/${contentId}.json`);
}

// Create content for root (/)
createContentFile('root');

// Create standard content files with rich content
console.log('Creating content files with rich content...');
Object.keys(realContentTemplates).forEach(contentId => {
    if (contentId !== 'default' && contentId !== 'root') {
        createContentFile(contentId);
    }
});

// Create content for specific files
console.log('Creating content for specific files...');
createContentFile('quick-start', '262c9362fd2f6e2f');
createContentFile('home', '5e8f84b66fd66837');

// Save the updated mapping
fs.writeFileSync(MAPPING_FILE_PATH, JSON.stringify(mapping, null, 2));
console.log(`Updated mapping file saved to ${MAPPING_FILE_PATH}`);

console.log('Content generation completed');
