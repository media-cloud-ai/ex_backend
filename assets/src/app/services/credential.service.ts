import { Injectable } from '@angular/core'
import { HttpClient } from '@angular/common/http'
import { Observable, of } from 'rxjs'
import { catchError, tap } from 'rxjs/operators'

import { Credential } from '../models/credential'
import { CredentialPage } from '../models/page/credential_page'

@Injectable()
export class CredentialService {
  private credentialsUrl = '/api/credentials'

  constructor(private http: HttpClient) {}

  getCredentials(): Observable<CredentialPage> {
    return this.http.get<CredentialPage>(this.credentialsUrl).pipe(
      tap((_credentialPage) => this.log('fetched CredentialPage')),
      catchError(this.handleError('getCredentials', undefined)),
    )
  }

  createCredential(key: string, value: string): Observable<Credential> {
    const params = {
      key: key,
      value: value,
    }
    return this.http.post<Credential>(this.credentialsUrl, params).pipe(
      tap((_credentialPage) => this.log('create Credential')),
      catchError(this.handleError('createCredential', undefined)),
    )
  }

  changeCredential(
    id: number,
    key: string,
    value: string,
  ): Observable<Credential> {
    const params = {
      id: id,
      credential: {
        key: key,
        value: value,
      },
    }
    console.log(params)
    return this.http
      .put<Credential>(this.credentialsUrl + '/' + id, params)
      .pipe(
        tap((_credentialPage) => this.log('change Credential')),
        catchError(this.handleError('changeCredential', undefined)),
      )
  }

  removeCredential(id: number): Observable<Credential> {
    return this.http.delete<Credential>(this.credentialsUrl + '/' + id).pipe(
      tap((_credentialPage) => this.log('remove Credential')),
      catchError(this.handleError('removeCredential', undefined)),
    )
  }

  private handleError<T>(operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`)
      return of(result as T)
    }
  }

  private log(message: string) {
    console.log('CredentialService: ' + message)
  }
}
