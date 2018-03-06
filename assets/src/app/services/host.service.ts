
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { of } from 'rxjs/observable/of';
import { catchError, tap } from 'rxjs/operators';

import { HostConfigPage } from '../models/page/host_config_page';

@Injectable()
export class HostService {
  private hostsUrl = 'api/docker/hosts';

  constructor(private http: HttpClient) { }

  getHosts(): Observable<HostConfigPage> {
    return this.http.get<HostConfigPage>(this.hostsUrl)
      .pipe(
        tap(hostConfigPage => this.log('fetched HostConfigPage')),
        catchError(this.handleError('getHosts', undefined))
      );
  }

  private handleError<T> (operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      console.error(error);
      this.log(`${operation} failed: ${error.message}`);
      return of(result as T);
    };
  }

  private log(message: string) {
    console.log('HostService: ' + message);
  }
}
