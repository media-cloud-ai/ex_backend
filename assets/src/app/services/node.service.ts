
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { of } from 'rxjs/observable/of';
import { catchError, tap } from 'rxjs/operators';

import { NodeConfigPage } from '../models/page/node_config_page';

@Injectable()
export class NodeService {
  private nodesUrl = 'api/docker/nodes';

  constructor(private http: HttpClient) { }

  getNodes(): Observable<NodeConfigPage> {
    return this.http.get<NodeConfigPage>(this.nodesUrl)
      .pipe(
        tap(nodeConfigPage => this.log('fetched NodeConfigPage')),
        catchError(this.handleError('getNodes', undefined))
      );
  }

  private handleError<T> (operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`);
      return of(result as T);
    };
  }

  private log(message: string) {
    console.log('NodeService: ' + message);
  }
}
