/**
 * Test script to verify content mapping files are accessible
 * This file should be placed in apps/nform-demo-app/src for testing
 */
import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'test-content',
  template: `
    <div>
      <h2>Content Mapping Test</h2>
      <div *ngIf="loading">Loading...</div>
      <div *ngIf="error" style="color: red">{{ error }}</div>
      <div *ngIf="!loading && !error">
        <h3>Files Available:</h3>
        <ul>
          <li *ngFor="let file of files">{{ file.url }}: {{ file.status }}</li>
        </ul>
      </div>
    </div>
  `
})
export class TestContentComponent implements OnInit {
  loading = true;
  error: string | null = null;
  files: { url: string; status: string }[] = [];

  constructor(private http: HttpClient) {}

  ngOnInit() {
    this.testFiles();
  }

  async testFiles() {
    const filesToTest = [
      '/assets/nform-content-mapping.json',
      '/assets/md-content/pages.json',
      '/assets/md-content/code-examples.json',
      '/assets/md-content/search-content.json',
      '/md-content/pages.json',
      '/md-content/code-examples.json',
      '/md-content/search-content.json'
    ];

    try {
      for (const url of filesToTest) {
        try {
          await this.http.get(url).toPromise();
          this.files.push({ url, status: 'Available ✅' });
        } catch (error) {
          this.files.push({ url, status: 'Not Found ❌' });
        }
      }
    } catch (error) {
      this.error = `Error testing files: ${error.message}`;
    } finally {
      this.loading = false;
    }

    // Log to console as well
    console.table(this.files);
  }
}

// Run this via ng serve and check the browser console
