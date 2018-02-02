import { Injectable } from '@angular/core';
import { HttpClient, HttpParams, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { of } from 'rxjs/observable/of';
import { catchError, map, tap } from 'rxjs/operators';

import {VideoPage} from './video_page';
import {DateRange} from './date_range';

@Injectable()
export class VideoService {
  private videosUrl = 'api/videos';

  constructor(private http: HttpClient) { }

  getVideos(page: number, channels: Array<string>, searchInput: string, dateRange: DateRange): Observable<VideoPage> {
    let params = new HttpParams();
    params = params.append('per_page', '10');
    params = params.append('type.id', 'integrale');
    for (let entry of channels) {
      params = params.append('channels[]', entry);
    }

    if(searchInput != ''){
      params = params.append('q', searchInput);
    }
    if(page > 0) {
      params = params.append('page', String(page + 1));
    }
    if(dateRange.getStart() != undefined){
      params = params.append('broadcasted_after', dateRange.getStart().format());
    }
    if(dateRange.getEnd() != undefined){
      params = params.append('broadcasted_before', dateRange.getEnd().format());
    }

    return this.http.get<VideoPage>(this.videosUrl, {params: params})
      .pipe(
        tap(videopage => this.log('fetched VideoPage')),
        catchError(this.handleError('getVideos', undefined))
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
    console.log('VideoService: ' + message);
  }
}
