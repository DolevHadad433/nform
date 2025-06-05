import { Injectable } from '@angular/core';
import { Customer, Person, Seller } from './datastore/models';
import { DATA_TYPES } from './datastore/protocols';
import { DatasourceAdapter } from './datasource-adapters/adapter';
import WorkerDatasourceAdapter from './datasource-adapters/worker';
import WindowDatasourceAdapter from './datasource-adapters/window';

@Injectable({ providedIn: 'root' })
export class DemoDataSource {
  ready: Promise<void>;

  private countries: any;
  private adapter: DatasourceAdapter;

  constructor() {
    if (typeof Worker !== 'undefined') {
      this.adapter = new WorkerDatasourceAdapter();
    } else {
      this.adapter = new WindowDatasourceAdapter();
    }
    this.ready = this.adapter.ready;
  }

  reset(...collections: Array<DATA_TYPES>): void { this.adapter.reset(...collections); }

  getCustomers(delay = 1000, limit = 500): Promise<Customer[]> { return this.adapter.getCustomers(delay, limit); }

  getPeople(delay = 1000, limit = 500): Promise<Person[]> { return this.adapter.getPeople(delay, limit); }

  getSellers(delay = 1000, limit = 500): Promise<Seller[]> { return this.adapter.getSellers(delay, limit); }

  getCountries() {
    return this.countries
      ? Promise.resolve(this.countries)
      : import('country-data').then( countryData => this.countries = countryData )
    ;
  }

  dispose(): void { this.adapter.dispose(); }
}

/**
 * Wait until an event matches given conditions
 */
export function eventWaitUntil(target: any, event: string, comparer: any): Promise<Event> {
  return new Promise((resolve) => {
    target.addEventListener(event, function handler(evt) {
      if (comparer(evt)) {
        target.removeEventListener(event, handler);
        resolve(evt);
      }
    });
  });
}
