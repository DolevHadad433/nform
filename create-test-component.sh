#!/bin/zsh
# Create a test file to diagnose ContentMapService issues
# This script creates a test component to visualize the content mapping service behavior

echo "Creating ContentMapService test component..."

# Create test component directory if it doesn't exist
TEST_DIR="apps/nform-demo-app/src/app/test-content"
mkdir -p "$TEST_DIR"

# Create the test component file
cat > "$TEST_DIR/test-content.component.ts" << 'EOL'
import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { ContentMapService } from '@pebula/apps/libs/shared/lib/services/content-map.service';

@Component({
  selector: 'app-test-content',
  template: `
    <div class="test-panel">
      <h2>Content Mapping Service Test</h2>
      
      <div *ngIf="loading">Loading content map service...</div>
      <div *ngIf="error" class="error">{{ error }}</div>
      
      <div *ngIf="contentMapData">
        <h3>Content Map Service Data:</h3>
        <pre>{{ contentMapData | json }}</pre>
      </div>
      
      <h3>File Access Tests:</h3>
      <div *ngFor="let test of fileTests">
        <div [class.success]="test.success" [class.error]="!test.success">
          {{ test.url }}: {{ test.success ? '✅' : '❌' }} 
          <span *ngIf="test.error">- {{ test.error }}</span>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .test-panel { padding: 20px; margin: 20px; border: 1px solid #ccc; border-radius: 4px; max-width: 800px; }
    .error { color: #f44336; }
    .success { color: #4CAF50; }
    pre { background: #f5f5f5; padding: 10px; border-radius: 4px; overflow: auto; }
  `]
})
export class TestContentComponent implements OnInit {
  loading = true;
  error: string | null = null;
  contentMapData: any = null;
  fileTests: Array<{ url: string, success: boolean, error?: string }> = [];

  constructor(
    private contentMapService: ContentMapService,
    private http: HttpClient
  ) {}

  ngOnInit() {
    this.testContentMapService();
    this.testFileAccess();
  }

  async testContentMapService() {
    try {
      this.contentMapData = await this.contentMapService.getMapping;
      console.log('ContentMapService data:', this.contentMapData);
    } catch (err) {
      this.error = `Error loading content map service: ${err.message}`;
      console.error('ContentMapService error:', err);
    } finally {
      this.loading = false;
    }
  }

  async testFileAccess() {
    // Define files to test
    const filesToTest = [
      '/assets/nform-content-mapping.json',
      '/assets/md-content/pages.json',
      '/assets/md-content/code-examples.json',
      '/assets/md-content/search-content.json',
      '/md-content/pages.json',
      '/md-content/code-examples.json',
      '/md-content/search-content.json'
    ];

    // Test each file
    for (const url of filesToTest) {
      try {
        await this.http.get(url).toPromise();
        this.fileTests.push({ url, success: true });
      } catch (err) {
        this.fileTests.push({ 
          url, 
          success: false, 
          error: err.status ? `HTTP ${err.status}` : err.message
        });
      }
    }
  }
}
EOL

# Create module file
cat > "$TEST_DIR/test-content.module.ts" << 'EOL'
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { HttpClientModule } from '@angular/common/http';
import { TestContentComponent } from './test-content.component';

@NgModule({
  declarations: [TestContentComponent],
  imports: [
    CommonModule,
    HttpClientModule,
    RouterModule.forChild([
      { path: '', component: TestContentComponent }
    ])
  ]
})
export class TestContentModule {}
EOL

# Update app routing to include test component
echo "Updating app routing..."

ROUTING_PATH="apps/nform-demo-app/src/app/app-routing.module.ts"

# Create a backup of the routing file
cp "$ROUTING_PATH" "${ROUTING_PATH}.backup"

# Add the test route to the routing configuration
sed -i '' -e '/const routes: Routes = \[/a\
  { path: "test-content", loadChildren: () => import("./test-content/test-content.module").then(m => m.TestContentModule) },
' "$ROUTING_PATH"

echo "Test component created at $TEST_DIR"
echo "Access it at: http://localhost:4201/test-content"
echo "You may need to restart your Angular server for changes to take effect."
