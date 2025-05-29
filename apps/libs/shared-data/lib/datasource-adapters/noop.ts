import { DatasourceAdapter } from './adapter';
import { Customer, Person, Seller } from '../datastore/models';
import { DATA_TYPES } from '../datastore/protocols';

export class WindowNoopDatasourceAdapter implements DatasourceAdapter {
  ready: Promise<void>;

  constructor() {
    this.ready = Promise.resolve();
  }

  reset(...collections: Array<DATA_TYPES>): void {
    // Noop implementation for server-side rendering
  }

  getCustomers(delay = 1000, limit = 500): Promise<Customer[]> {
    return Promise.resolve([]);
  }

  getPeople(delay = 1000, limit = 500): Promise<Person[]> {
    return Promise.resolve([]);
  }

  getSellers(delay = 1000, limit = 500): Promise<Seller[]> {
    return Promise.resolve([]);
  }

  dispose(): void {
    // Noop implementation
  }
}

export default WindowNoopDatasourceAdapter;
