import { Customer, Person, Seller } from '../datastore/models';
import { DATA_TYPES } from '../datastore/protocols';

export interface DatasourceAdapter {
  ready: Promise<void>;
  
  reset(...collections: Array<DATA_TYPES>): void;
  
  getCustomers(delay?: number, limit?: number): Promise<Customer[]>;
  
  getPeople(delay?: number, limit?: number): Promise<Person[]>;
  
  getSellers(delay?: number, limit?: number): Promise<Seller[]>;
  
  dispose(): void;
}
