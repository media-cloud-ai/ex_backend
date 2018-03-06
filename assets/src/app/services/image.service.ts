
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { of } from 'rxjs/observable/of';
import { catchError, tap } from 'rxjs/operators';

import { ImagePage } from '../models/page/image_page';

@Injectable()
export class ImageService {
  private imagesUrl = 'api/docker/images';

  constructor(private http: HttpClient) { }

  getImages(): Observable<ImagePage> {
    return this.http.get<ImagePage>(this.imagesUrl)
      .pipe(
        tap(imagePage => this.log('fetched ImagePage')),
        catchError(this.handleError('getImages', undefined))
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
    console.log('ImageService: ' + message);
  }
}
