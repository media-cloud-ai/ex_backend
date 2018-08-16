
import { Injectable } from '@angular/core'
import { HttpClient } from '@angular/common/http'
import { Observable, of } from 'rxjs'
import { catchError, tap } from 'rxjs/operators'

import { NodeConfigPage } from '../models/page/node_config_page'
import { NodeConfig } from '../models/node_config'

@Injectable()
export class NodeService {
  private nodesUrl = 'api/docker/nodes'
  private testUrl = 'api/docker/test'
  constructor(private http: HttpClient) { }

  getNodes(): Observable<NodeConfigPage> {
    return this.http.get<NodeConfigPage>(this.nodesUrl)
      .pipe(
        tap(nodeConfigPage => this.log('fetched NodeConfigPage')),
        catchError(this.handleError('getNodes', undefined))
      )
  }

  addNode(config: NodeConfig): Observable<NodeConfigPage> {
    return this.http.post<NodeConfigPage>(this.nodesUrl, {node: config})
      .pipe(
        tap(nodeConfigPage => this.log('fetched NodeConfigPage')),
        catchError(this.handleError('addNode', undefined))
      )
  }

  deleteNode(node_id: number): Observable<NodeConfigPage> {
    return this.http.delete<NodeConfigPage>(this.nodesUrl + '/' + node_id)
      .pipe(
        tap(nodeConfigPage => this.log('fetched NodeConfigPage')),
        catchError(this.handleError('deleteNode', undefined))
      )
  }

  testConnection(config: NodeConfig): Observable<NodeConfigPage> {
    return this.http.post<NodeConfigPage>(this.testUrl, {config: config})
      .pipe(
        tap(nodeConfigPage => this.log('fetched NodeConfigPage')),
        catchError(this.handleError('testConnection', undefined))
      )
  }

  private handleError<T> (operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`)
      return of(result as T)
    }
  }

  private log(message: string) {
    console.log('NodeService: ' + message)
  }
}
