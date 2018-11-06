import { Injectable } from '@angular/core'
import { HttpClient, HttpParams, HttpHeaders } from '@angular/common/http'
import { Observable, of } from 'rxjs'
import { catchError, map, tap } from 'rxjs/operators'

import {CatalogPage, CatalogData} from '../models/page/catalog_page'
import {DateRange} from '../models/date_range'
import {IngestResponse} from '../models/ingest_response'

@Injectable()
export class CatalogService {
  private catalogUrl = 'api/catalog'

  constructor(private http: HttpClient) { }

  getVideos(
    page: number,
    per_page: number,
    channels: Array<string>,
    searchInput: string,
    dateRange: DateRange,
    videoid: string,
    live: boolean,
    integrale: boolean)
  : Observable<CatalogPage> {

    let params = new HttpParams()
    params = params.append('per_page', per_page.toString())
    if (integrale === true) {
      params = params.append('type.id', 'integrale')
    }
    if (live === true) {
      params = params.append('broadcasted_live', 'true')
    }
    for (let entry of channels) {
      params = params.append('channels[]', entry)
    }

    if (searchInput !== ''){
      params = params.append('q', searchInput)
    }
    if (videoid.length === 36){
      params = params.append('qid', videoid)
    }
    if (page > 0) {
      params = params.append('page', String(page + 1))
    }
    if (dateRange.getStart() !== undefined){
      params = params.append('broadcasted_after', dateRange.getStart().format())
    }
    if (dateRange.getEnd() !== undefined){
      params = params.append('broadcasted_before', dateRange.getEnd().format())
    }

    params = params.append('sort', '-broadcasted_at')

    return this.http.get<CatalogPage>(this.catalogUrl, {params: params})
      .pipe(
        tap(videoPage => this.log('fetched VideoPage')),
        catchError(this.handleError('getVideos', undefined))
      )
  }

  getVideo(video_id: string)
  : Observable<CatalogData> {
    return this.http.get<CatalogData>(this.catalogUrl + '/' + video_id)
      .pipe(
        tap(video => this.log('fetched Video')),
        catchError(this.handleError('getVideo', undefined))
      )
  }

  ingest(video_id: number): Observable<IngestResponse> {
    const url = `${this.catalogUrl}/${video_id}`

    return this.http.put<IngestResponse>(url, {})
      .pipe(
        tap(response => this.log('update Video')),
        catchError(this.handleError('putVideos', undefined))
      )
  }

  private handleError<T> (operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`)
      return of(result as T)
    }
  }

  private log(message: string) {
    console.log('CatalogService: ' + message)
  }
}
