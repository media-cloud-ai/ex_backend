import { Injectable } from '@angular/core'
import { HttpClient, HttpParams } from '@angular/common/http'
import { Observable, of } from 'rxjs'
import { catchError, tap } from 'rxjs/operators'

import { WatcherPage } from '../models/page/watcher_page'

@Injectable()
export class WatcherService {
  private watchersUrl = '/api/watchers'

  constructor(private http: HttpClient) {}

  getWatchers(): Observable<WatcherPage> {
    const _params = new HttpParams()

    return this.http.get<WatcherPage>(this.watchersUrl).pipe(
      tap((_watcherPage) => this.log('fetched WatcherPage')),
      catchError(this.handleError('getWatchers', undefined)),
    )
  }

  private handleError<T>(operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`)
      return of(result as T)
    }
  }

  private log(message: string) {
    console.log('WatcherService: ' + message)
  }
}
