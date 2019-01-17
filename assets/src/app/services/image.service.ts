
import { Injectable } from '@angular/core'
import { HttpClient, HttpParams } from '@angular/common/http'
import { Observable, of } from 'rxjs'
import { catchError, tap } from 'rxjs/operators'

import { ImagePage } from '../models/page/image_page'

@Injectable()
export class ImageService {
  private imagesUrl = '/api/docker/images'

  constructor(private http: HttpClient) { }

  getImages(node_id?: number): Observable<ImagePage> {
    let params = new HttpParams()
    if (node_id) {
      params = params.append('node_id', node_id.toString())
    }
    return this.http.get<ImagePage>(this.imagesUrl, {params: params})
      .pipe(
        tap(imagePage => this.log('fetched ImagePage')),
        catchError(this.handleError('getImages', undefined))
      )
  }

  updateImage(worker_id: number, image_id: string): Observable<ImagePage> {
    return this.http.put<ImagePage>(this.imagesUrl + "/" + image_id, {"node_id": worker_id}, {})
      .pipe(
        tap(imagePage => this.log('update Image')),
        catchError(this.handleError('updateImage', undefined))
      )
  }

  deleteImage(worker_id: number, image_id: string): Observable<{}> {
    return this.http.delete<ImagePage>(this.imagesUrl + "/" + image_id + "?node_id=" + worker_id.toString())
      .pipe(
        catchError(this.handleError('deleteImage', "Error"))
      )
  }

  private handleError<T> (operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`)
      return of(result as T)
    }
  }

  private log(message: string) {
    console.log('ImageService: ' + message)
  }
}
