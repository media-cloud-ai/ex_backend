import { Injectable } from '@angular/core'
import { HttpClient, HttpParams, HttpHeaders } from '@angular/common/http'
import { Observable, of } from 'rxjs'
import { catchError, map, tap } from 'rxjs/operators'

import { IMDbPeople } from '../models/person'

@Injectable()
export class IMDbService {
  private imdbUrl = '/api/imdb'

  constructor(private http: HttpClient) {}

  search(query: string): Observable<any> {
    return this.http.get<any>(this.imdbUrl + '/search/' + query).pipe(
      tap((searchData) => this.log('search IMDb people', searchData)),
      catchError(this.handleError('search', undefined)),
    )
  }

  getPeople(imdb_id: string): Observable<IMDbPeople> {
    return this.http.get<IMDbPeople>(this.imdbUrl + '/' + imdb_id).pipe(
      tap((peopleData) => this.log('fetched IMDb people', peopleData)),
      catchError(this.handleError('getPeople', undefined)),
    )
  }

  private handleError<T>(operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`)
      return of(result as T)
    }
  }

  private log(message: string, obj?: object) {
    console.log('IMDbService: ' + message, obj)
  }
}
