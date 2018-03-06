
import { Injectable } from '@angular/core';
import { HttpClient, HttpParams, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { of } from 'rxjs/observable/of';
import { catchError, map, tap } from 'rxjs/operators';

import {
  ContainerConfig,
  Container,
  ContainersPage,
  HostsPage,
  HostConfig
} from './containers_page';

@Injectable()
export class ContainersService {
  private containersUrl = 'api/docker/containers';
  private hostsUrl = 'api/docker/hosts';

  constructor(private http: HttpClient) { }

  getHosts(): Observable<HostsPage> {
    let params = new HttpParams();
    return this.http.get<HostsPage>(this.hostsUrl, {params: params})
      .pipe(
        tap(containerspage => this.log('fetched HostsPage')),
        catchError(this.handleError('getHosts', undefined))
      );
  }

  getContainers(): Observable<ContainersPage> {
    let params = new HttpParams();
    return this.http.get<ContainersPage>(this.containersUrl, {params: params})
      .pipe(
        tap(containerspage => this.log('fetched ContainersPage')),
        catchError(this.handleError('getContainers', undefined))
      );
  }

  createContainer(docker_host_config: HostConfig, container_name: string, container_config: ContainerConfig): Observable<Container> {
    let params = {
      docker_host_config: docker_host_config,
      container_name: container_name,
      container_config: container_config
    };
    return this.http.post<Container>(this.containersUrl, params)
      .pipe(
        tap(containerspage => this.log('create Container')),
        catchError(this.handleError('createContainer', undefined))
      );
  }

  removeContainer(id: string): Observable<Container> {
    return this.http.delete<Container>(this.containersUrl + "/" + id)
      .pipe(
        tap(containerspage => this.log('remove Container')),
        catchError(this.handleError('removeContainer', undefined))
      );
  }

  updateContainer(id: string, action: string): Observable<Container> {
    return this.http.post<Container>(this.containersUrl + "/" + id + "/" + action, {})
      .pipe(
        tap(containerspage => this.log('update Container')),
        catchError(this.handleError('updateContainer', undefined))
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
    console.log('ContainersService: ' + message);
  }
}
