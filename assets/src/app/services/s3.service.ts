import { Injectable } from '@angular/core'
import { HttpClient, HttpParams } from '@angular/common/http'
import { Observable, of } from 'rxjs'
import { catchError, tap } from 'rxjs/operators'

import { S3Configuration } from '../models/s3'

@Injectable()
export class S3Service {
  private s3ConfigUrl = '/api/s3_config'
  private s3PresignUrl = '/api/s3_presign_url'

  constructor(private http: HttpClient) {}

  getConfiguration(): Observable<S3Configuration> {
    return this.http.get<S3Configuration>(this.s3ConfigUrl).pipe(
      tap((userPage) => this.log('fetched S3Configuration')),
      catchError(this.handleError('getConfiguration', undefined)),
    )
  }

  getPresignedUrl(path: string): Observable<any> {
    let params = new HttpParams()
    params = params.append('path', path)

    return this.http
      .get<S3Configuration>(this.s3PresignUrl, { params: params })
      .pipe(
        tap((userPage) => this.log('fetched S3Configuration')),
        catchError(this.handleError('getPresignedUrl', undefined)),
      )
  }

  private handleError<T>(operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`)
      return of(result as T)
    }
  }

  private log(message: string) {
    console.log('S3Service: ' + message)
  }
}
