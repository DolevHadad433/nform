import { tap, finalize } from 'rxjs/operators';
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import type { DynamicExportedObject } from '@pebula-internal/webpack-dynamic-dictionary';

declare const NFORM_CONTENT_MAPPING_FILE: string;

const CONTENT_MAPPING_FILE = typeof NFORM_CONTENT_MAPPING_FILE !== 'undefined'
  ? NFORM_CONTENT_MAPPING_FILE
  : 'nform-content-mapping.json';

@Injectable({ providedIn: 'root' })
export class ContentMapService {

  private isDevEnvironment = typeof window !== 'undefined' && window.location ? window.location.port === '4201' : false;
  get getMapping(): Promise<DynamicExportedObject> {
    if (!this.mapping) {
      if (!this.fetching) {
        const mappingPath = this.isDevEnvironment ?
          '/nform-content-mapping.json' :
          CONTENT_MAPPING_FILE;
        this.fetching = this.httpClient.get<DynamicExportedObject>(mappingPath + `?dt=${Date.now()}`)
          .pipe(
            tap(mapping => {
              this.mapping = mapping;
            }),
            finalize(() => {
              this.fetching = undefined;
            }),
          )
          .toPromise();
      }
      return this.fetching;
    } else {
      return Promise.resolve(this.mapping);
    }
  }

  private fetching: Promise<DynamicExportedObject>;
  private mapping: DynamicExportedObject;

  constructor(private httpClient: HttpClient) { }
}
