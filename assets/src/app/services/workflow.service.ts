
import { Injectable } from '@angular/core';
import { HttpClient, HttpParams, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { of } from 'rxjs/observable/of';
import { catchError, map, tap } from 'rxjs/operators';

import {WorkflowPage} from './workflow_page';
import {Step, Workflow} from './workflow';

@Injectable()
export class WorkflowService {
  private workflowsUrl = 'api/workflows';

  constructor(private http: HttpClient) { }

  getWorkflows(page: number): Observable<WorkflowPage> {
    let params = new HttpParams();
    if(page > 0) {
      params = params.append('page', String(page + 1));
    }

    return this.http.get<WorkflowPage>(this.workflowsUrl, {params: params})
      .pipe(
        tap(workflowpage => this.log('fetched WorkflowPage')),
        catchError(this.handleError('getWorkflows', undefined))
      );
  }

  createWorkflow(workflow: Workflow): Observable<Workflow> {
    return this.http.post<Workflow>(this.workflowsUrl, {workflow: workflow})
      .pipe(
        tap(workflowpage => this.log('fetched Workflow')),
        catchError(this.handleError('createWorkflow', undefined))
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
    console.log('WorkflowService: ' + message);
  }
}
