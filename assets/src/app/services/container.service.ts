
import { Injectable } from '@angular/core'
import { HttpClient, HttpParams, HttpHeaders } from '@angular/common/http'
import { Observable, of } from 'rxjs'
import { catchError, map, tap } from 'rxjs/operators'

import { Container } from '../models/container'
import { ContainerPage } from '../models/page/container_page'
import { NodeConfig } from '../models/node_config'
import { ImageParameters } from '../models/image'

@Injectable()
export class ContainerService {
  private containersUrl = 'api/docker/containers'

  constructor(private http: HttpClient) { }

  getContainers(): Observable<ContainerPage> {
    let params = new HttpParams()
    return this.http.get<ContainerPage>(this.containersUrl, {params: params})
      .pipe(
        tap(containerPage => this.log('fetched ContainerPage')),
        catchError(this.handleError('getContainers', undefined))
      )
  }

  createContainer(node_id: number, container_name: string, image_parameters: ImageParameters): Observable<Container> {
    let params = {
      node_id: node_id,
      container_name: container_name,
      image_parameters: image_parameters
    }
    return this.http.post<Container>(this.containersUrl, params)
      .pipe(
        tap(containerPage => this.log('create Container')),
        catchError(this.handleError('createContainer', undefined))
      )
  }

  removeContainer(id: string): Observable<Container> {
    return this.http.delete<Container>(this.containersUrl + '/' + id)
      .pipe(
        tap(containerPage => this.log('remove Container')),
        catchError(this.handleError('removeContainer', undefined))
      )
  }

  updateContainer(id: string, action: string): Observable<Container> {
    return this.http.post<Container>(this.containersUrl + '/' + id + '/' + action, {})
      .pipe(
        tap(containerPage => this.log('update Container')),
        catchError(this.handleError('updateContainer', undefined))
      )
  }

  private handleError<T> (operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`)
      return of(result as T)
    }
  }

  private log(message: string) {
    console.log('ContainersService: ' + message)
  }
}
