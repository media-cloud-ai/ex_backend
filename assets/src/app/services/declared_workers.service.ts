import { Injectable } from '@angular/core'
import { HttpClient } from '@angular/common/http'
import { Observable, of } from 'rxjs'
import { catchError, tap } from 'rxjs/operators'

import { DeclaredWorkersPage } from '../models/page/declared_workers_page'

@Injectable()
export class DeclaredWorkersService {
  private imagesUrl = '/api/step_flow/worker_definitions'

  constructor(private http: HttpClient) {}

  getWorkers(): Observable<DeclaredWorkersPage> {
    return this.http.get<DeclaredWorkersPage>(this.imagesUrl).pipe(
      tap((imagePage) => this.log('fetched DeclaredWorkersPage')),
      catchError(this.handleError('getWorkers', undefined)),
    )
  }

  private handleError<T>(operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`)
      return of(result as T)
    }
  }

  private log(message: string) {
    console.log('DeclaredWorkersService: ' + message)
  }
}
