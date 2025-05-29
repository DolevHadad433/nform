import { DatasourceAdapter } from './adapter';
import { Customer, Person, Seller } from '../datastore/models';
import { DATA_TYPES } from '../datastore/protocols';

export class WindowDatasourceAdapter implements DatasourceAdapter {
  ready: Promise<void>;
  private store: import('../datastore/datastore').DataStore;

  constructor() {
    this.ready = import('../datastore/datastore')
      .then( datastore => {
        this.store = new  datastore.DataStore();
      });
  }

  reset(...collections: Array<DATA_TYPES>): void { 
    this.store.reset(...collections); 
  }
  
  getCustomers(delay = 1000, limit = 500): Promise<Customer[]> { 
    return this.store.getCustomers(delay, limit); 
  }
  
  getPeople(delay = 1000, limit = 500): Promise<Person[]> { 
    return this.store.getPeople(delay, limit); 
  }
  
  getSellers(delay = 1000, limit = 500): Promise<Seller[]> { 
    return this.store.getSellers(delay, limit); 
  }

  dispose(): void { 
    // Nothing to dispose for window adapter
  }
}

export default WindowDatasourceAdapter;
