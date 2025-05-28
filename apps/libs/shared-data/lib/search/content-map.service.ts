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

// Auto-generated content mappings

export const CONTENT_MAPPINGS = {
  "advanced-controls-example": {
    "file": "assets/pbl-advanced-controls-example-cb91a81157105203.json",
    "path": "/assets/pbl-advanced-controls-example-cb91a81157105203.json",
    "hasContent": true
  },
  "arrays-example": {
    "file": "assets/pbl-arrays-example-af564e27c80cac7b.json",
    "path": "/assets/pbl-arrays-example-af564e27c80cac7b.json",
    "hasContent": true
  },
  "before-render-example": {
    "file": "assets/pbl-before-render-example-7d5db033e5282109.json",
    "path": "/assets/pbl-before-render-example-7d5db033e5282109.json",
    "hasContent": true
  },
  "child-forms-example": {
    "file": "assets/pbl-child-forms-example-57e5129132e8c3bc.json",
    "path": "/assets/pbl-child-forms-example-57e5129132e8c3bc.json",
    "hasContent": true
  },
  "complex-data-structures-example": {
    "file": "assets/pbl-complex-data-structures-example-a3a1ed96af72359e.json",
    "path": "/assets/pbl-complex-data-structures-example-a3a1ed96af72359e.json",
    "hasContent": true
  },
  "controlling-nform-example": {
    "file": "assets/pbl-controlling-nform-example-ae0be050c47b82a5.json",
    "path": "/assets/pbl-controlling-nform-example-ae0be050c47b82a5.json",
    "hasContent": true
  },
  "disable-example": {
    "file": "assets/pbl-disable-example-0d5a2c66ae71eeb7.json",
    "path": "/assets/pbl-disable-example-0d5a2c66ae71eeb7.json",
    "hasContent": true
  },
  "disable-form-example": {
    "file": "assets/pbl-disable-form-example-a7a7f15ab54d0f9e.json",
    "path": "/assets/pbl-disable-form-example-a7a7f15ab54d0f9e.json",
    "hasContent": true
  },
  "field-sync-redraw-example": {
    "file": "assets/pbl-field-sync-redraw-example-94aabe8d65f93444.json",
    "path": "/assets/pbl-field-sync-redraw-example-94aabe8d65f93444.json",
    "hasContent": true
  },
  "flattening-example": {
    "file": "assets/pbl-flattening-example-d43bcc97d177dc4b.json",
    "path": "/assets/pbl-flattening-example-d43bcc97d177dc4b.json",
    "hasContent": true
  },
  "flex-form-layout-example": {
    "file": "assets/pbl-flex-form-layout-example-8a2df19b0238619a.json",
    "path": "/assets/pbl-flex-form-layout-example-8a2df19b0238619a.json",
    "hasContent": true
  },
  "form-layout-pinning-example": {
    "file": "assets/pbl-form-layout-pinning-example-daecd10bf69f0263.json",
    "path": "/assets/pbl-form-layout-pinning-example-daecd10bf69f0263.json",
    "hasContent": true
  },
  "form-splitting-example": {
    "file": "assets/pbl-form-splitting-example-63a82476d5387831.json",
    "path": "/assets/pbl-form-splitting-example-63a82476d5387831.json",
    "hasContent": true
  },
  "guide-index-example": {
    "file": "assets/pbl-guide-index-example-d4795def84280205.json",
    "path": "/assets/pbl-guide-index-example-d4795def84280205.json",
    "hasContent": true
  },
  "guide-intro-example": {
    "file": "assets/pbl-guide-intro-example-936e8a8c288aaf4b.json",
    "path": "/assets/pbl-guide-intro-example-936e8a8c288aaf4b.json",
    "hasContent": true
  },
  "hide-filter-controls-example": {
    "file": "assets/pbl-hide-filter-controls-example-6298b824609213b3.json",
    "path": "/assets/pbl-hide-filter-controls-example-6298b824609213b3.json",
    "hasContent": true
  },
  "horizontal-form-layout-example": {
    "file": "assets/pbl-horizontal-form-layout-example-67b430faed3556e2.json",
    "path": "/assets/pbl-horizontal-form-layout-example-67b430faed3556e2.json",
    "hasContent": true
  },
  "hot-binding-example": {
    "file": "assets/pbl-hot-binding-example-a899510123091bb7.json",
    "path": "/assets/pbl-hot-binding-example-a899510123091bb7.json",
    "hasContent": true
  },
  "imperative-example": {
    "file": "assets/pbl-imperative-example-87fc0ddb3dded274.json",
    "path": "/assets/pbl-imperative-example-87fc0ddb3dded274.json",
    "hasContent": true
  },
  "model-form-sync-example": {
    "file": "assets/pbl-model-form-sync-example-b0207a420f451b95.json",
    "path": "/assets/pbl-model-form-sync-example-b0207a420f451b95.json",
    "hasContent": true
  },
  "nform-basics-example": {
    "file": "assets/pbl-nform-basics-example-d830686fb57d4540.json",
    "path": "/assets/pbl-nform-basics-example-d830686fb57d4540.json",
    "hasContent": true
  },
  "render-state-example": {
    "file": "assets/pbl-render-state-example-9ae48702a21b094d.json",
    "path": "/assets/pbl-render-state-example-9ae48702a21b094d.json",
    "hasContent": true
  },
  "template-overrides-example": {
    "file": "assets/pbl-template-overrides-example-bbb9feb3e83da138.json",
    "path": "/assets/pbl-template-overrides-example-bbb9feb3e83da138.json",
    "hasContent": true
  },
  "the-renderer-example": {
    "file": "assets/pbl-the-renderer-example-bf1abbb0e627f5b8.json",
    "path": "/assets/pbl-the-renderer-example-bf1abbb0e627f5b8.json",
    "hasContent": true
  },
  "validation-example": {
    "file": "assets/pbl-validation-example-e36e2d2883a9bc86.json",
    "path": "/assets/pbl-validation-example-e36e2d2883a9bc86.json",
    "hasContent": true
  },
  "value-changes-example": {
    "file": "assets/pbl-value-changes-example-072a3c16a184886a.json",
    "path": "/assets/pbl-value-changes-example-072a3c16a184886a.json",
    "hasContent": true
  },
  "vertical-form-layout-example": {
    "file": "assets/pbl-vertical-form-layout-example-7f4ff2dae2f75852.json",
    "path": "/assets/pbl-vertical-form-layout-example-7f4ff2dae2f75852.json",
    "hasContent": true
  },
  "virtual-groups-example": {
    "file": "assets/pbl-virtual-groups-example-30224075efbd75be.json",
    "path": "/assets/pbl-virtual-groups-example-30224075efbd75be.json",
    "hasContent": true
  },
  "virtual-groups-wizard-example": {
    "file": "assets/pbl-virtual-groups-wizard-example-dc589b5104239927.json",
    "path": "/assets/pbl-virtual-groups-wizard-example-dc589b5104239927.json",
    "hasContent": true
  }
};
