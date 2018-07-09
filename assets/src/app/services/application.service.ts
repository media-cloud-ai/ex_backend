import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { catchError, tap } from 'rxjs/operators';

import {Application} from '../models/application';

@Injectable()
export class ApplicationService {
  private applicationUrl = 'app';

  constructor(private http: HttpClient) { }

  get(): Observable<Application> {
    return this.http.get<Application>(this.applicationUrl)
      .pipe(
        tap(application => this.log('fetched Application')),
        catchError(this.handleError('get', undefined))
      );
  }

  private handleError<T> (operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`);
      return of(result as T);
    };
  }

  private log(message: string) {
    console.log('ApplicationService: ' + message);
  }
}
