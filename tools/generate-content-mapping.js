// Generate nform-content-mapping.json
const path = require('path');
const fs = require('fs');

// Output file name
const NFORM_CONTENT_MAPPING_FILE = 'nform-content-mapping.json';

// Create directories if they don't exist
const distDir = path.resolve(__dirname, '../dist');
const mdContentDir = path.resolve(distDir, 'md-content');

if (!fs.existsSync(distDir)) {
  fs.mkdirSync(distDir, { recursive: true });
}

if (!fs.existsSync(mdContentDir)) {
  fs.mkdirSync(mdContentDir, { recursive: true });
}

// Create content files for pages and code examples
// Create code examples file with sample examples
const codeExamples = {
  "examples": [
    {
      "id": "basic-form",
      "title": "Basic Form Example",
      "language": "typescript",
      "code": "import { Component } from '@angular/core';\nimport { NFormStatic } from '@pebula/nform';\n\n@Component({\n  selector: 'app-basic-form',\n  template: `<pbl-nform [model]=\"person\"></pbl-nform>`\n})\nexport class BasicFormComponent {\n  person = {\n    name: 'John Doe',\n    email: 'john@example.com',\n    age: 30\n  };\n}"
    },
    {
      "id": "custom-template",
      "title": "Custom Template Example",
      "language": "typescript",
      "code": "import { Component } from '@angular/core';\nimport { NFormStatic } from '@pebula/nform';\n\n@Component({\n  selector: 'app-custom-template',\n  template: `\n    <pbl-nform [model]=\"user\">\n      <ng-template pblNFormOverride=\"email\">\n        <div>Custom Email Field: {{user.email}}</div>\n      </ng-template>\n    </pbl-nform>\n  `\n})\nexport class CustomTemplateComponent {\n  user = {\n    name: 'Jane Doe',\n    email: 'jane@example.com'\n  };\n}"
    },
    {
      "id": "validation",
      "title": "Validation Example",
      "language": "typescript",
      "code": "import { Component } from '@angular/core';\nimport { NFormStatic, NFormValidator } from '@pebula/nform';\nimport { Validators } from '@angular/forms';\n\n@Component({\n  selector: 'app-validation',\n  template: `<pbl-nform [model]=\"data\"></pbl-nform>`\n})\nexport class ValidationComponent {\n  @NFormValidator('email', Validators.email)\n  @NFormValidator('name', Validators.required)\n  data = {\n    name: '',\n    email: ''\n  };\n}"
    },
    {
      "id": "array-model",
      "title": "Array Model Example",
      "language": "typescript",
      "code": "import { Component } from '@angular/core';\nimport { NFormStatic } from '@pebula/nform';\n\n@Component({\n  selector: 'app-array-model',\n  template: `<pbl-nform [model]=\"contacts\"></pbl-nform>`\n})\nexport class ArrayModelComponent {\n  contacts = [\n    { name: 'John', phone: '555-1234' },\n    { name: 'Jane', phone: '555-5678' },\n    { name: 'Bob', phone: '555-8765' }\n  ];\n}"
    },
    {
      "id": "nested-form",
      "title": "Nested Form Example",
      "language": "typescript",
      "code": "import { Component } from '@angular/core';\nimport { NFormStatic } from '@pebula/nform';\n\n@Component({\n  selector: 'app-nested-form',\n  template: `<pbl-nform [model]=\"customer\"></pbl-nform>`\n})\nexport class NestedFormComponent {\n  customer = {\n    name: 'Alice Johnson',\n    address: {\n      street: '123 Main St',\n      city: 'Springfield',\n      state: 'IL',\n      zip: '62704'\n    }\n  };\n}"
    }
  ]
};

fs.writeFileSync(path.join(mdContentDir, 'code-examples.json'), JSON.stringify(codeExamples, null, 2));
console.log(`Created code-examples.json in ${mdContentDir}`);

// Create pages file with sample pages - format that matches PageNavigationMetadata
const pages = {
  "entries": {
    "/": {
      "title": "Home",
      "path": "/",
      "type": "index"
    },
    "guide": {
      "title": "Guide",
      "path": "guide",
      "type": "topMenuSection",
      "tooltip": "How-to Guide",
      "searchGroup": "guide",
      "ordinal": 1,
      "children": [
        {
          "title": "Guide Introduction",
          "path": "guide/introduction",
          "tooltip": "How-to use the guide",
          "ordinal": 0
        },
        {
          "title": "Basics",
          "path": "guide/basics",
          "ordinal": 0,
          "children": [
            {
              "title": "nForm Basics",
              "path": "guide/basics/nform-basics",
              "ordinal": 0
            },
            {
              "title": "Disable",
              "path": "guide/basics/disable",
              "ordinal": 1
            },
            {
              "title": "Form Layout",
              "path": "guide/basics/form-layout",
              "tags": [
                "form",
                "layout",
                "order",
                "ordinal"
              ],
              "ordinal": 1
            },
            {
              "title": "Form Layout Pinning",
              "path": "guide/basics/form-layout-pinning",
              "tags": [
                "form",
                "layout",
                "pin"
              ],
              "ordinal": 2
            },
            {
              "title": "Hide / Filter Controls",
              "path": "guide/basics/hide-or-filter-controls",
              "ordinal": 2
            },
            {
              "title": "Hot Binding",
              "path": "guide/basics/hot-binding",
              "ordinal": 3
            },
            {
              "title": "Validation",
              "path": "guide/basics/validation",
              "ordinal": 4
            },
            {
              "title": "Sync: Model <-> Form",
              "path": "guide/basics/model-form-sync",
              "ordinal": 5
            },
            {
              "title": "Template Overrides",
              "path": "guide/basics/template-overrides",
              "ordinal": 6
            },
            {
              "title": "Form Splitting",
              "path": "guide/basics/form-splitting",
              "ordinal": 7
            },
            {
              "title": "Advanced Controls",
              "path": "guide/basics/advanced-controls",
              "ordinal": 8
            }
          ]
        },
        {
          "title": "Events",
          "path": "guide/events",
          "searchGroup": "events",
          "ordinal": 1,
          "children": [
            {
              "title": "(beforeRender)",
              "path": "guide/events/before-render",
              "tags": [
                "events",
                "beforeRender"
              ],
              "ordinal": 0
            },
            {
              "title": "(renderState)",
              "path": "guide/events/render-state",
              "tags": [
                "events",
                "renderState"
              ],
              "ordinal": 1
            },
            {
              "title": "(valueChanges)",
              "path": "guide/events/value-changes",
              "tags": [
                "events",
                "valueChanges"
              ],
              "ordinal": 2
            },
            {
              "title": "Field Sync / Field Redraw",
              "path": "guide/events/field-sync-redraw",
              "tags": [
                "events",
                "sync",
                "redraw"
              ],
              "ordinal": 3
            }
          ]
        },
        {
          "title": "Layout",
          "path": "guide/layout",
          "ordinal": 2,
          "children": [
            {
              "title": "The Renderer",
              "path": "guide/layout/the-renderer",
              "ordinal": 0
            }
          ]
        },
        {
          "title": "Advanced Modeling",
          "path": "guide/advanced-modeling",
          "ordinal": 3,
          "children": [
            {
              "title": "Controlling Nform",
              "path": "guide/advanced-modeling/controlling-nform",
              "ordinal": 0
            },
            {
              "title": "Complex Data Structures",
              "path": "guide/advanced-modeling/complex-data-structures",
              "ordinal": 1
            },
            {
              "title": "Nested Forms: Child Forms",
              "path": "guide/advanced-modeling/child-forms",
              "ordinal": 2
            },
            {
              "title": "Nested Forms: Flattening",
              "path": "guide/advanced-modeling/flattening",
              "ordinal": 3
            },
            {
              "title": "Arrays",
              "path": "guide/advanced-modeling/arrays",
              "ordinal": 4
            }
          ]
        }
      ]
    },
    "quick-start": {
      "title": "Quick Start",
      "path": "quick-start",
      "type": "topMenuSection",
      "tooltip": "Quick Start",
      "searchGroup": "quick-start",
      "ordinal": 0
    }
  },
  "entryData": {
    "/": "md-content5e8f84b66fd66837.json",
    "guide/introduction": "md-contentguide-intro/6024bf20223e39a0.json",
    "guide": "md-contentguide/4095937b4d200c89.json",
    "quick-start": "md-contentquick-start/262c9362fd2f6e2f.json",
    "guide/basics/advanced-controls": "md-contentguide/basics/advanced-controls/2ffcbbb6677ad0d6.json",
    "guide/basics/disable": "md-contentguide/basics/disable/56565768d736b818.json",
    "guide/basics/form-layout": "md-contentguide/basics/form-layout/8eb74da852b329be.json",
    "guide/basics/form-layout-pinning": "md-contentguide/basics/form-layout-pinning/be74ed71d9e529f1.json",
    "guide/basics/form-splitting": "md-contentguide/basics/form-splitting/b731676f726c2fb8.json",
    "guide/basics/hot-binding": "md-contentguide/basics/hot-binding/4d2d70588211e135.json",
    "guide/basics/hide-or-filter-controls": "md-contentguide/basics/hide-filter-controls/35940c759178f787.json",
    "guide/basics/model-form-sync": "md-contentguide/basics/model-form-sync/9bfa0bc6df9200d5.json",
    "guide/basics/nform-basics": "md-contentguide/basics/nform-basics/7084a93229fa485c.json",
    "guide/basics/template-overrides": "md-contentguide/basics/template-overrides/067352f4533378e0.json",
    "guide/advanced-modeling/arrays": "md-contentguide/advanced-modeling/arrays/2353498babeddfea.json",
    "guide/basics/validation": "md-contentguide/basics/validation/b271bf48786a8e1b.json",
    "guide/advanced-modeling/child-forms": "md-contentguide/advanced-modeling/child-forms/0a858f07e4fbb45e.json",
    "guide/advanced-modeling/controlling-nform": "md-contentguide/advanced-modeling/controlling-nform/dbe10b8c644b40da.json",
    "guide/advanced-modeling/complex-data-structures": "md-contentguide/advanced-modeling/complex-data-structures/7bdb31691b15d130.json",
    "guide/events/before-render": "md-contentguide/events/before-render/01787288f998d53b.json",
    "guide/advanced-modeling/flattening": "md-contentguide/advanced-modeling/flattening/d9e210c19c649f9c.json",
    "guide/events/render-state": "md-contentguide/events/render-state/5cfed2ea2cf1a022.json",
    "guide/events/field-sync-redraw": "md-contentguide/events/field-sync-redraw/471e2f05f2ad3a44.json",
    "guide/events/value-changes": "md-contentguide/events/value-changes/a5327c9f51f8836d.json",
    "guide/layout/the-renderer": "md-contentguide/layout/the-renderer/f2b48b48beee4c2f.json"
  }
};

fs.writeFileSync(path.join(mdContentDir, 'pages.json'), JSON.stringify(pages, null, 2));
console.log(`Created pages.json in ${mdContentDir}`);

// Create individual page content files
const pageContents = {
  "home": {
    "id": "home",
    "title": "Home",
    "contents": "# Welcome to NForm\n\nThis is the home page for the NForm documentation."
  },
  "getting-started": {
    "id": "getting-started",
    "title": "Getting Started",
    "contents": "# Getting Started with NForm\n\nFollow these steps to get started with NForm in your Angular application."
  },
  "guide": {
    "id": "guide",
    "title": "Guide",
    "contents": "# NForm Guide\n\nThis guide provides comprehensive documentation for using NForm."
  },
  "quick-start": {
    "id": "quick-start",
    "title": "Quick Start",
    "contents": "# Quick Start\n\nA quick introduction to NForm to get you up and running."
  },
  "advanced-usage": {
    "id": "advanced-usage",
    "title": "Advanced Usage",
    "contents": "# Advanced Usage\n\nLearn about advanced features and capabilities of NForm."
  },
  "guide/basics": {
    "id": "guide/basics",
    "title": "Basics",
    "contents": "# NForm Basics\n\nBasic usage and concepts for NForm."
  },
  "guide/advanced-modeling": {
    "id": "guide/advanced-modeling",
    "title": "Advanced Modeling",
    "contents": "# Advanced Modeling\n\nLearn about advanced data modeling with NForm."
  },
  "guide/events": {
    "id": "guide/events",
    "title": "Events",
    "contents": "# NForm Events\n\nLearn about the events system in NForm."
  }
};

// Create individual page files
Object.entries(pageContents).forEach(([key, content]) => {
  fs.writeFileSync(path.join(mdContentDir, `${key.replace('/', '-')}.json`), JSON.stringify(content, null, 2));
  console.log(`Created ${key.replace('/', '-')}.json in ${mdContentDir}`);
});

// Create search content file with proper structure
const searchContent = [
  {
    "path": "/",
    "title": "Home",
    "titleWords": "home",
    "headingWords": "",
    "keywords": ""
  },
  {
    "path": "guide",
    "title": "Guide",
    "titleWords": "guide",
    "headingWords": "NForm Guide",
    "keywords": ""
  },
  {
    "path": "guide/introduction",
    "title": "Guide Introduction",
    "titleWords": "guide introduction",
    "headingWords": "Guide: How to The Dashboard Real time form status indicator LED Source code view Form / Model interaction menu",
    "keywords": ""
  },
  {
    "path": "quick-start",
    "title": "Quick Start",
    "titleWords": "quick start",
    "headingWords": "QuickStart Install NgModule setup",
    "keywords": ""
  },
  {
    "path": "guide/advanced-modeling/arrays",
    "title": "Arrays",
    "titleWords": "arrays",
    "headingWords": "Arrays",
    "keywords": ""
  },
  {
    "path": "guide/advanced-modeling/child-forms",
    "title": "Nested Forms: Child Forms",
    "titleWords": "nested child forms",
    "headingWords": "Child Forms Nested models A known model Explicitly declared Adding address Displaying a child form Child from using inline control override Child from using the renderer Control Outlet A note on the renderer",
    "keywords": ""
  },
  {
    "path": "guide/advanced-modeling/complex-data-structures",
    "title": "Complex Data Structures",
    "titleWords": "complex data structures",
    "headingWords": "Complex Data Structures Adding depth Object Child Forms Flattening Arrays Array of primitive Array of Object Working with arrays Tools",
    "keywords": ""
  },
  {
    "path": "guide/advanced-modeling/controlling-nform",
    "title": "Controlling Nform",
    "titleWords": "controlling nform",
    "headingWords": "Controlling NForm NForm Read/Write Working with Arrays Working with child forms",
    "keywords": ""
  },
  {
    "path": "guide/advanced-modeling/flattening",
    "title": "Nested Forms: Flattening",
    "titleWords": "nested flattening",
    "headingWords": "Flattening",
    "keywords": ""
  },
  {
    "path": "guide/basics/advanced-controls",
    "title": "Advanced Controls",
    "titleWords": "advanced controls",
    "headingWords": "Advanced Controls",
    "keywords": ""
  },
  {
    "path": "guide/basics/disable",
    "title": "Disable",
    "titleWords": "disable",
    "headingWords": "Disable Disable specific control Disable the Form",
    "keywords": ""
  },
  {
    "path": "guide/basics/form-layout",
    "title": "Form Layout",
    "titleWords": "form layout",
    "headingWords": "Form Layout Declaring pbl-nform Creating meta driven layout Control Rendering Order Breaking the Layout",
    "keywords": "form layout order ordinal"
  },
  {
    "path": "guide/basics/form-layout-pinning",
    "title": "Form Layout Pinning",
    "titleWords": "form layout pinning",
    "headingWords": "Form Layout Pinning Location Only",
    "keywords": "form layout pin"
  },
  {
    "path": "guide/basics/form-splitting",
    "title": "Form Splitting",
    "titleWords": "form splitting",
    "headingWords": "Form Splitting Outlet Splitting Virtual Groups slaveOF Wizards",
    "keywords": ""
  },
  {
    "path": "guide/basics/hide-or-filter-controls",
    "title": "Hide / Filter Controls",
    "titleWords": "hide filter controls",
    "headingWords": "Hide / Filter Controls Hiding Controls Filtering Controls Inverting the filter Filtered fields and Validation",
    "keywords": ""
  },
  {
    "path": "guide/basics/hot-binding",
    "title": "Hot Binding",
    "titleWords": "hot binding",
    "headingWords": "Hot Binding",
    "keywords": ""
  },
  {
    "path": "guide/basics/model-form-sync",
    "title": "Sync: Model <-> Form",
    "titleWords": "model form",
    "headingWords": "Model <-> Form Sync The NForm class Commit (Form -> Model) Sync (Model -> Form)",
    "keywords": ""
  },
  {
    "path": "guide/basics/nform-basics",
    "title": "nForm Basics",
    "titleWords": "nform basics",
    "headingWords": "nForm Basics",
    "keywords": ""
  },
  {
    "path": "guide/basics/template-overrides",
    "title": "Template Overrides",
    "titleWords": "template overrides",
    "headingWords": "Template Overrides Control Query Catch all / Fallback Declarative Overrides Targeting overrides by type Imperative Overrides Precedence",
    "keywords": ""
  },
  {
    "path": "guide/basics/validation",
    "title": "Validation",
    "titleWords": "validation",
    "headingWords": "Validation Required Dynamic Validation",
    "keywords": ""
  },
  {
    "path": "guide/events/before-render",
    "title": "(beforeRender)",
    "titleWords": "beforerender",
    "headingWords": "beforeRender Event Notifying about async operations NFormRecordRef",
    "keywords": "events beforeRender"
  },
  {
    "path": "guide/events/field-sync-redraw",
    "title": "Field Sync / Field Redraw",
    "titleWords": "field sync field redraw",
    "headingWords": "Field Sync / Form Redraw Redraw Field Sync What should I use",
    "keywords": "events sync redraw"
  },
  {
    "path": "guide/events/render-state",
    "title": "(renderState)",
    "titleWords": "renderstate",
    "headingWords": "renderState Event",
    "keywords": "events renderState"
  },
  {
    "path": "guide/events/value-changes",
    "title": "(valueChanges)",
    "titleWords": "valuechanges",
    "headingWords": "valueChanges Event Working with changes Updating values Updating in (valueChanges) is safe valueChanges and nested objects",
    "keywords": "events valueChanges"
  },
  {
    "path": "guide/layout/the-renderer",
    "title": "The Renderer",
    "titleWords": "the renderer",
    "headingWords": "The Renderer",
    "keywords": ""
  }
];

fs.writeFileSync(path.join(mdContentDir, 'search-content.json'), JSON.stringify(searchContent, null, 2));
console.log(`Created search-content.json in ${mdContentDir}`);

// Create the mapping file
const mappingContent = {
  markdownPages: "md-content/pages.json",
  markdownCodeExamples: "md-content/code-examples.json",
  searchContent: "md-content/search-content.json"
};

fs.writeFileSync(path.join(distDir, NFORM_CONTENT_MAPPING_FILE), JSON.stringify(mappingContent, null, 2));
console.log(`Created ${NFORM_CONTENT_MAPPING_FILE} in ${distDir}`);

console.log('Content mapping files generated successfully');
