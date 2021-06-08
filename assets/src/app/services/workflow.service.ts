
import { Injectable } from '@angular/core'
import { formatDate } from '@angular/common'
import { HttpClient, HttpParams, HttpHeaders } from '@angular/common/http'
import { Observable, of } from 'rxjs'
import { catchError, map, tap } from 'rxjs/operators'

import { WorkflowQueryParams, WorkflowPage, WorkflowData, WorkflowHistory } from '../models/page/workflow_page'
import { Step, Workflow, WorkflowEvent } from '../models/workflow'
import { StartWorkflowDefinition } from '../models/startWorkflowDefinition'

@Injectable()
export class WorkflowService {
  private workflowUrl = '/api/workflow'
  private workflowsUrl = '/api/step_flow/workflows'
  private workflowIdentifiersUrl = '/api/step_flow/definitions_identifiers'
  private workflowsLauncher = '/api/step_flow/launch_workflow'
  private workflowDefinitionsUrl = '/api/step_flow/definitions'
  private statisticsUrl = '/api/step_flow/workflows_statistics'

  constructor(private http: HttpClient) { }

  getWorkflowDefinitions(page?: number, per_page?: number, right_action?: string, search?: string, versions?: string[], mode?: string): Observable<WorkflowPage> {
    let params = new HttpParams()
    if (per_page) {
      params = params.append('size', per_page.toString())
    }
    if (page > 0) {
      params = params.append('page', String(page))
    }
    if (right_action) {
      params = params.append("right_action", right_action)
    }
    if (search) {
      params = params.append("search", search)
    }
    for (let version of versions) {
      params = params.append("versions[]", version)
    }
    if (mode) {
      params = params.append("mode", mode)
    }
    return this.http.get<WorkflowPage>(this.workflowDefinitionsUrl, { params: params })
      .pipe(
        tap(workflowPage => this.log('fetched WorkflowPage')),
        catchError(this.handleError('getWorkflowDefinitions', undefined))
      )
  }

  getWorkflows(page: number, per_page: number, parameters: WorkflowQueryParams): Observable<WorkflowPage> {
    let params = new HttpParams()

    if (per_page) {
      params = params.append('size', per_page.toString())
    }
    if (page > 0) {
      params = params.append('page', String(page))
    }
    for (let identifier of parameters.identifiers) {
      params = params.append('identifiers[]', identifier)
    }
    for (let state of parameters.status) {
      params = params.append('states[]', state)
    }
    params = params.append('after_date', formatDate(parameters.start_date, "yyyy-MM-ddTHH:mm:ss", "fr"))
    params = params.append('before_date', formatDate(parameters.end_date, "yyyy-MM-ddTHH:mm:ss", "fr"))

    return this.http.get<WorkflowPage>(this.workflowsUrl, { params: params })
      .pipe(
        tap(workflowPage => this.log('fetched WorkflowPage')),
        catchError(this.handleError('getWorkflows', undefined))
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
