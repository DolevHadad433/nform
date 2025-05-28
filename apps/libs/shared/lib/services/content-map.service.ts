// filepath: /Users/eliranbrami/projects/nform/apps/libs/shared/lib/services/content-map.service.ts
import { tap, finalize } from 'rxjs/operators';
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import type { DynamicExportedObject } from '@pebula-internal/webpack-dynamic-dictionary';


declare const NFORM_CONTENT_MAPPING_FILE: string;

declare const CONTENT_SERVER_URL: string;

const CONTENT_MAPPING_FILE = typeof NFORM_CONTENT_MAPPING_FILE !== 'undefined'
  ? NFORM_CONTENT_MAPPING_FILE
  : 'nform-content-mapping.json';

@Injectable({ providedIn: 'root' })
export class ContentMapService {
  // Debug settings
  private debugMode = true;
  private logPrefix = '[ContentMapService]';

  // Development environment detection - if port is 4201, we're in dev mode
  private isDevEnvironment = typeof window !== 'undefined' && window.location ? window.location.port === '4201' : false;

  // Content server URL for direct file access - use webpack-provided value if available
  private contentServerUrl = typeof CONTENT_SERVER_URL !== 'undefined'
    ? CONTENT_SERVER_URL
    : (this.isDevEnvironment ? 'http://localhost:4201' : '');

  // Transform a path to use the content server for special paths
  public transformPath(path: string): string {
    if (!path) return path;

    if (this.isDevEnvironment) {
      // Handle all md-content paths, whether they have slashes or not
      // This covers patterns like md-content/file.json and md-content5e8f84b66fd66837.json
      if (path.startsWith('md-content')) {
        const transformedPath = `${this.contentServerUrl}/${path}`;
        return transformedPath;
      }
    }

    return path;
  }

  get getMapping(): Promise<DynamicExportedObject> {
    if (!this.mapping) {
      if (!this.fetching) {
        // Choose mapping path based on environment
        const mappingPath = this.isDevEnvironment ?
          '/nform-content-mapping.json' :
          CONTENT_MAPPING_FILE;


        this.fetching = this.httpClient.get<DynamicExportedObject>(mappingPath + `?dt=${Date.now()}`)
          .pipe(
            tap((mapping: DynamicExportedObject) => {
              this.mapping = mapping;
            }),
            finalize(() => {
              this.fetching = undefined;
            })
          ).toPromise();
      }
      return this.fetching;
    } else {
      return Promise.resolve(this.mapping);
    }
  }

  private fetching: Promise<DynamicExportedObject>;
  private mapping: DynamicExportedObject;

  constructor(private httpClient: HttpClient) {
  }
}
