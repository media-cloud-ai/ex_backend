
import { Injectable } from '@angular/core'
import { HttpClient, HttpParams, HttpHeaders } from '@angular/common/http'
import { Observable, of } from 'rxjs'
import { catchError, map, tap } from 'rxjs/operators'

import {WorkflowIdentifiersData, WorkflowQueryParams, WorkflowPage, WorkflowData, WorkflowHistory} from '../models/page/workflow_page'
import {Step, Workflow, WorkflowEvent} from '../models/workflow'
import {StartWorkflowDefinition} from '../models/startWorkflowDefinition'

@Injectable()
export class WorkflowService {
  private workflowUrl = '/api/workflow'
  private workflowsUrl = '/api/step_flow/workflows'
  private workflowIdentifiersUrl = '/api/step_flow/definitions_identifiers'
  private workflowsLauncher = '/api/step_flow/launch_workflow'
  private workflowDefinitionsUrl = '/api/step_flow/definitions'
  private statisticsUrl = '/api/step_flow/workflows_statistics'

  constructor(private http: HttpClient) { }

  getWorkflowDefinitions(page?: number, per_page?: number): Observable<WorkflowPage> {
    let params = new HttpParams()
    if (per_page) {
      params = params.append('size', per_page.toString())
    }
    if (page > 0) {
      params = params.append('page', String(page))
    }
    return this.http.get<WorkflowPage>(this.workflowDefinitionsUrl, { params: params })
      .pipe(
        tap(workflowPage => this.log('fetched WorkflowPage')),
        catchError(this.handleError('getWorkflowDefinitions', undefined))
      )
  }

  getWorkflows(page: number, per_page: number, video_id: string, status: Array<string>, workflows: Array<string>, ids: Array<number>, after_date: any, before_date: any): Observable<WorkflowPage> {
    let params = new HttpParams()
    if (per_page) {
      params = params.append('size', per_page.toString())
    }
    if (page > 0) {
      params = params.append('page', String(page))
    }
    if (video_id !== '' && video_id !== undefined) {
      params = params.append('video_id', video_id)
    }
    if (after_date !== '' && after_date !== undefined) {
      params = params.append('after_date', after_date)
    }
    if (before_date !== '' && before_date !== undefined) {
      params = params.append('before_date', before_date)
    }
    for (let state of status) {
      params = params.append('state[]', state)
    }
    for (let workflow_id of workflows) {
      params = params.append('workflow_ids[]', workflow_id)
    }
    for (let id of ids) {
      if (id) {
        params = params.append('ids[]', id.toString())
      }
    }

    return this.http.get<WorkflowPage>(this.workflowsUrl, { params: params })
      .pipe(
        tap(workflowPage => this.log('fetched WorkflowPage')),
        catchError(this.handleError('getWorkflows', undefined))
      )
  }

  getWorkflowIdentifiers(action: string): Observable<WorkflowIdentifiersData> {
    return this.http.get<WorkflowIdentifiersData>(this.workflowIdentifiersUrl  + '/' + action)
      .pipe(
        tap(workflowPage => this.log('fetched Identifiers')),
        catchError(this.handleError('getWorkflowIdentifiers', undefined))
      )
  }

  getWorkflowDefinition(workflow_identifier: string, reference: string): Observable<Workflow> {
    let params = new HttpParams()
    params = params.append('reference', reference)

    return this.http.get<Workflow>(this.workflowUrl + '/' + workflow_identifier, { params: params })
      .pipe(
        tap(workflowPage => this.log('fetched Workflow')),
        catchError(this.handleError('getWorkflowDefinition', undefined))
      )
  }

  getWorkflow(workflow_id: number): Observable<WorkflowData> {
    return this.http.get<WorkflowData>(this.workflowsUrl + '/' + workflow_id.toString())
      .pipe(
        tap(workflowPage => this.log('fetched Workflow')),
        catchError(this.handleError('getWorkflow', undefined))
      )
  }

  createWorkflow(startWorkflowDefinition: StartWorkflowDefinition): Observable<WorkflowData> {
    return this.http.post<WorkflowData>(this.workflowsLauncher, startWorkflowDefinition)
      .pipe(
        tap(workflowPage => this.log('fetched Workflow')),
        catchError(this.handleError('createWorkflow', undefined))
      )
  }

  sendWorkflowEvent(workflow_id: number, event: WorkflowEvent): Observable<Workflow> {
    return this.http.post<Workflow>(this.workflowsUrl + '/' + workflow_id + '/events', event)
      .pipe(
        tap(workflowPage => this.log(event.event + ' Workflow')),
        catchError(this.handleError('abortWorkflow', undefined))
      )
  }

  getWorkflowStatistics(parameters: WorkflowQueryParams): Observable<WorkflowHistory> {
    let params = new HttpParams()

    for (let identifier of parameters.identifiers) {
      params = params.append('identifiers[]', identifier)
    }
    params = params.append('time_interval', parameters.time_interval.toString())
    params = params.append('start_date', parameters.start_date.toISOString())
    params = params.append('end_date', parameters.end_date.toISOString())

    return this.http.get<Workflow>(this.statisticsUrl, { params: params })
      .pipe(
        tap(workflowPage => this.log('statistics Workflow')),
        catchError(this.handleError('getWorkflowStatistics', undefined))
      )
  }

  private handleError<T>(operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`)
      return of(result as T)
    }
  }

  private log(message: string) {
    console.log('WorkflowService: ' + message)
  }
}
