
import { Injectable } from '@angular/core'
import { HttpClient, HttpParams, HttpHeaders } from '@angular/common/http'
import { Observable, of } from 'rxjs'
import { catchError, map, tap } from 'rxjs/operators'

import { WorkerPage } from '../models/page/worker_page'

@Injectable()
export class WorkerService {
  private workersUrl = '/api/step_flow/live_workers'
  private workerStatusesUrl = '/api/step_flow/workers'

  constructor(private http: HttpClient) { }

  getWorkers(statuses: string[]): Observable<WorkerPage> {
    let params = new HttpParams()

    if (statuses.includes("initializing")) {
      params = params.append('initializing', "true") 
    }

    if (statuses.includes("started")) {
      params = params.append('started', "true") 
    }

    if (statuses.includes("terminated")) {
      params = params.append('terminated', "true") 
    }

    return this.http.get<WorkerPage>(this.workersUrl, {params: params})
      .pipe(
        tap(workerPage => this.log('fetched WorkerPage')),
        catchError(this.handleError('getWorkers', undefined))
      )
  }

  sendWorkerOrderMessage(instance_id: string, message: object): Observable<any> {
    console.log("Send order to worker:", instance_id, message);

    return this.http.put<any>(this.workerStatusesUrl + '/' + instance_id, message)
      .pipe(
        tap(registery => this.log('put worker order message')),
        catchError(this.handleError('sendWorkerOrderMessage', undefined))
      )
  }

  private handleError<T> (operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`)
      return of(result as T)
    }
  }

  private log(message: string) {
    console.log('WorkersService: ' + message)
  }
}
