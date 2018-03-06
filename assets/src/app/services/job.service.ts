
import { Injectable } from '@angular/core';
import { HttpClient, HttpParams, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { of } from 'rxjs/observable/of';
import { catchError, map, tap } from 'rxjs/operators';

import {JobPage} from '../models/page/job_page';

@Injectable()
export class JobService {
  private jobsUrl = 'api/jobs';

  constructor(private http: HttpClient) { }

  getJobs(page: number): Observable<JobPage> {
    let params = new HttpParams();
    if(page > 0) {
      params = params.append('page', String(page + 1));
    }

    return this.http.get<JobPage>(this.jobsUrl, {params: params})
      .pipe(
        tap(jobPage => this.log('fetched JobPage')),
        catchError(this.handleError('getJobs', undefined))
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
    console.log('JobService: ' + message);
  }
}
