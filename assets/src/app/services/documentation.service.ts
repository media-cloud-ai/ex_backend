import { Injectable } from '@angular/core'
import { HttpClient } from '@angular/common/http'
import { Observable, of } from 'rxjs'
import { catchError, tap } from 'rxjs/operators'

import { DocumentationPage } from '../models/page/documentation_page'

@Injectable()
export class DocumentationService {
  private imagesUrl = '/api/documentation'

  constructor(private http: HttpClient) {}

  getDocumentation(): Observable<DocumentationPage> {
    return this.http.get<DocumentationPage>(this.imagesUrl).pipe(
      tap((imagePage) => this.log('fetched DocumentationPage')),
      catchError(this.handleError('getImages', undefined)),
    )
  }

  private handleError<T>(operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`)
      return of(result as T)
    }
  }

  private log(message: string) {
    console.log('DocumentationService: ' + message)
  }
}
