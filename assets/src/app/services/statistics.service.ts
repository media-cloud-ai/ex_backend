
import { Injectable } from '@angular/core'
import { formatDate } from '@angular/common'
import { HttpClient, HttpParams, HttpHeaders } from '@angular/common/http'
import { Observable, of } from 'rxjs'
import { catchError, map, tap } from 'rxjs/operators'

import { DurationStatistics, JobDurations, JobDurationStatistics, WorkflowDurations, WorkflowDurationStatistics } from '../models/statistics/duration'

@Injectable()
export class StatisticsService {
  private durationsUrl = '/api/step_flow/durations'
  private durationsStatisticsUrl = '/api/step_flow/statistics/durations'

  constructor(private http: HttpClient) { }

  getWorkflowDurations(workflow_id: number): Observable<WorkflowDurations> {
    let params = new HttpParams()
    params = params.append('workflow_id', String(workflow_id))

    return this.http.get<WorkflowDurations>(this.durationsUrl + "/workflows", { params: params })
      .pipe(
        tap(workflowDurations => this.log('fetched WorkflowDurations')),
        catchError(this.handleError('getWorkflowDurations', undefined))
      )
  }

  getWorkflowsDurations(workflow_ids: number[]): Observable<WorkflowDurations> {
    let params = new HttpParams()
    for (let workflow_id of workflow_ids) {
      params = params.append('ids[]', String(workflow_id))
    }

    return this.http.get<WorkflowDurations>(this.durationsUrl + "/workflows", { params: params })
      .pipe(
        tap(workflowDurations => this.log('fetched WorkflowDurations')),
        catchError(this.handleError('getWorkflowsDurations', undefined))
      )
  }

  getWorkflowsDurationStatistics(parameters = []): Observable<WorkflowDurationStatistics> {
    let params = new HttpParams()

    for(let item of parameters) {
      params = params.append(item["key"], String(item["value"]))
    }

    return this.http.get<WorkflowDurationStatistics>(this.durationsStatisticsUrl + "/workflows", { params: params })
      .pipe(
        tap(workflowDurations => this.log('fetched WorkflowDurationStatistics')),
        catchError(this.handleError('getWorkflowsDurationStatistics', undefined))
      )
  }

  getJobDurationStatistics(parameters = []): Observable<JobDurationStatistics> {
    let params = new HttpParams()

    for(let item of parameters) {
      params = params.append(item["key"], String(item["value"]))
    }

    return this.http.get<JobDurationStatistics>(this.durationsStatisticsUrl + "/jobs", { params: params })
      .pipe(
        tap(workflowDurations => this.log('fetched JobDurationStatistics')),
        catchError(this.handleError('getJobsDurationStatistics', undefined))
      )
  }

  getJobDurations(job_id: string): Observable<JobDurations> {
    let params = new HttpParams()
    params = params.append('job_id', job_id)

    return this.http.get<JobDurations>(this.durationsUrl + "/jobs", { params: params })
      .pipe(
        tap(jobDurations => this.log('fetched JobDurations')),
        catchError(this.handleError('getJobDurations', undefined))
      )
  }

  private handleError<T>(operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`)
      return of(result as T)
    }
  }

  private log(message: string) {
    console.log('StatisticsService: ' + message)
  }
}
