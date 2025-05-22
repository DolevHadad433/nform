import { Subject } from 'rxjs';
import { map, debounceTime } from 'rxjs/operators';
import { Component, ViewChild, OnDestroy, ChangeDetectorRef } from '@angular/core';
import { ActivatedRoute } from '@angular/router';

import { UnRx } from '@pebula/utils';
import { TocAreaDirective } from '../../toc.module';

import { MarkdownPagesMenuService } from '../../services/markdown-pages-menu.service';

// These constants are usually defined by webpack's DefinePlugin
// Adding fallbacks in case they're not defined at runtime
declare const ANGULAR_VERSION: string;
declare const CDK_VERSION: string;
declare const NFORM_VERSION: string;
declare const BUILD_VERSION: string;

// Function to get version constants from the generated file if global constants are not defined
function getVersionConstants() {
  try {
    // Try to load from the generated constants file
    // Using dynamic import with path relative to the build output
    const constants = require('/dist/webpack-constants.json');
    return {
      angular: constants.ANGULAR_VERSION,
      cdk: constants.CDK_VERSION,
      nform: constants.NFORM_VERSION,
      build: constants.BUILD_VERSION
    };
  } catch (err) {
    // Log the error only in development
    if (typeof window !== 'undefined' && window.location.hostname === 'localhost') {
      console.warn('Could not load webpack constants file:', err.message);
    }

    // Fallback to package.json versions when possible, otherwise hardcoded values
    try {
      // This might not work in production builds
      const pkgAngular = require('@angular/core/package.json');
      const pkgCdk = require('@angular/cdk/package.json');
      const pkgNform = require('@pebula/nform/package.json');

      return {
        angular: pkgAngular.version || '16.1.0',
        cdk: pkgCdk.version || '16.1.0',
        nform: pkgNform.version || '15.0.7',
        build: 'dev'
      };
    } catch (pkgErr) {
      // Final fallback to hardcoded values
      return {
        angular: '16.1.0',
        cdk: '16.1.0',
        nform: '15.0.7',
        build: 'dev'
      };
    }
  }
}

@Component({
  selector: 'pbl-markdown-page-container',
  templateUrl: './markdown-page-container.component.html',
  styleUrls: ['./markdown-page-container.component.scss']
})
@UnRx()
export class MarkdownPageContainerComponent implements OnDestroy {

  entry: string;
  documentUrl: string;
  @ViewChild('tocArea', { static: true, read: TocAreaDirective }) tocArea: TocAreaDirective;

  menu$ = new Subject<any>();

  // Try to use the webpack-defined constants, but fall back to loaded constants if not available
  private constants = getVersionConstants();
  ngVersion = typeof ANGULAR_VERSION !== 'undefined' ? ANGULAR_VERSION : this.constants.angular;
  cdkVersion = typeof CDK_VERSION !== 'undefined' ? CDK_VERSION : this.constants.cdk;
  libVersion = typeof NFORM_VERSION !== 'undefined' ? NFORM_VERSION : this.constants.nform;
  buildVersion = typeof BUILD_VERSION !== 'undefined' ? BUILD_VERSION : this.constants.build;

  constructor(private mdPagesMenu: MarkdownPagesMenuService, private route: ActivatedRoute, private cdr: ChangeDetectorRef) { }

  ngAfterViewInit(): void {
    this.route.url
      .pipe(
        debounceTime(1),
        map(urlSegments => urlSegments.map(u => u.path)),
        UnRx(this)
      )
      .subscribe(paths => this.handleUrlUpdate(paths));
  }

  ngOnDestroy(): void {
    this.menu$.complete();
  }

  getRouterLink(path: string): any[] {
    const routeLink = path.split('/');
    if (routeLink[0] !== '/') {
      routeLink.unshift('/');
    }
    return routeLink;
  }

  contentRendered(): void {
    this.tocArea.reinitQueryLinks(Promise.resolve())
      .then(() => this.cdr.detectChanges());
  }

  private handleUrlUpdate(paths: string[]): void {
    if (this.entry !== paths[0]) {
      this.entry = paths[0];
      this.mdPagesMenu.getMenu(this.entry)
        .then(entry => {
          this.menu$.next(entry);
        })
        .catch(err => this.menu$.next(null));
    }

    this.documentUrl = paths.length ? paths.join('/') : '/';
  }
}
