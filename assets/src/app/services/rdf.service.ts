
import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { of } from 'rxjs/observable/of';
import { catchError, tap } from 'rxjs/operators';

import {Rdf} from '../models/rdf';

@Injectable()
export class RdfService {
  constructor(private http: HttpClient) { }

  getRdf(video_id: number): Observable<Rdf> {
    let rdfUrl = 'api/videos/' + video_id + '/rdf';
    let params = {};

    return this.http.get<Rdf>(rdfUrl, params)
      .pipe(
        tap(jobPage => this.log('fetched Rdf')),
        catchError(this.handleError('ingestRdf', undefined))
      );
  }

  ingestRdf(video_id: number): Observable<Rdf> {
    let rdfUrl = 'api/videos/' + video_id + '/rdf';
    let params = {};

    return this.http.post<Rdf>(rdfUrl, params)
      .pipe(
        tap(jobPage => this.log('fetched Rdf')),
        catchError(this.handleError('ingestRdf', undefined))
      );
  }

  private handleError<T> (operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`);
      return of(result as T);
    };
  }

  private log(message: string) {
    console.log('RdfService: ' + message);
  }
}
