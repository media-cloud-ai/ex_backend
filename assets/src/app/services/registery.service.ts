import { Injectable } from '@angular/core'
import { HttpClient, HttpParams, HttpHeaders } from '@angular/common/http'
import { Observable, of } from 'rxjs'
import { catchError, map, tap } from 'rxjs/operators'

import {RegisteryPage, RegisteryData} from '../models/page/registery_page'
import {DateRange} from '../models/date_range'
import {IngestResponse} from '../models/ingest_response'

@Injectable()
export class RegisteryService {
  private registeryUrl = 'api/registery'

  constructor(private http: HttpClient) { }

  getRegisteries(
    page: number,
    per_page: number,
    searchInput: string)
  : Observable<RegisteryPage> {

    let params = new HttpParams()
    params = params.append('size', per_page.toString())

    if (searchInput !== ''){
      params = params.append('search', searchInput)
    }
    if (page > 0) {
      params = params.append('page', String(page + 1))
    }

    return this.http.get<RegisteryPage>(this.registeryUrl, {params: params})
      .pipe(
        tap(registeryPage => this.log('fetched RegisteriesPage')),
        catchError(this.handleError('getRegisteries', undefined))
      )
  }

  getRegistery(registery_id: string)
  : Observable<RegisteryData> {
    return this.http.get<RegisteryData>(this.registeryUrl + '/' + registery_id)
      .pipe(
        tap(registery => this.log('fetched Registery')),
        catchError(this.handleError('getRegistery', undefined))
      )
  }

  private handleError<T> (operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`)
      return of(result as T)
    }
  }

  private log(message: string) {
    console.log('RegisteryService: ' + message)
  }
}
