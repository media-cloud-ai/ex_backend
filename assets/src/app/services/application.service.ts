import { Injectable } from '@angular/core'
import { HttpClient } from '@angular/common/http'
import { Observable, of } from 'rxjs'
import { catchError, tap } from 'rxjs/operators'

import { Application } from '../models/application'

@Injectable()
export class ApplicationService {
  private applicationUrl = '/app'
  application = undefined

  constructor(private http: HttpClient) {}

  get_cached_app(): Observable<Application> {
    if (this.application !== undefined) {
      return of(this.application)
    }

    return this.get()
  }

  get(): Observable<Application> {
    return this.http.get<Application>(this.applicationUrl).pipe(
      tap((application) => {
        this.application = application
        this.log('fetched Application')
      }),
      catchError(this.handleError('get', undefined)),
    )
  }

  private handleError<T>(operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`)
      return of(result as T)
    }
  }

  private log(message: string) {
    console.log('ApplicationService: ' + message)
  }
}
