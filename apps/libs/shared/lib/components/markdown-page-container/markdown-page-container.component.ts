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

  // Using the typeof operator to check if constants are defined, otherwise use fallback values
  ngVersion = typeof ANGULAR_VERSION !== 'undefined' ? ANGULAR_VERSION : '16.1.0';
  cdkVersion = typeof CDK_VERSION !== 'undefined' ? CDK_VERSION : '16.1.0';
  libVersion = typeof NFORM_VERSION !== 'undefined' ? NFORM_VERSION : '15.0.7';
  buildVersion = typeof BUILD_VERSION !== 'undefined' ? BUILD_VERSION : 'dev';

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
