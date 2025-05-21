// filepath: /Users/eliranbrami/projects/nform/apps/libs/shared/lib/services/content-map.service.ts
import { tap, finalize } from 'rxjs/operators';
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import type { DynamicExportedObject } from '@pebula-internal/webpack-dynamic-dictionary';

// Using fallback value if webpack doesn't define it
declare const NFORM_CONTENT_MAPPING_FILE: string;

// Fallback mapping file path if the constant is not defined during build
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

  get getMapping(): Promise<DynamicExportedObject> {
    if (!this.mapping) {
      if (!this.fetching) {
        // Choose mapping path based on environment
        const mappingPath = this.isDevEnvironment ? 
          '/nform-content-mapping.json' : 
          CONTENT_MAPPING_FILE;
        
        if (this.debugMode) {
          console.log(`${this.logPrefix} Fetching mapping from: ${mappingPath}, dev mode: ${this.isDevEnvironment}`);
        }
        
        this.fetching = this.httpClient.get<DynamicExportedObject>(mappingPath + `?dt=${Date.now()}`)
          .pipe(
            tap((mapping: DynamicExportedObject) => {
              if (this.debugMode) {
                console.log(`${this.logPrefix} Mapping loaded:`, mapping);
              }
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
    if (this.debugMode) {
      console.log(`${this.logPrefix} Initializing, dev mode: ${this.isDevEnvironment}`);
    }
  }
}
