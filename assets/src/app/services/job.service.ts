import { Injectable } from '@angular/core'
import { HttpClient, HttpParams } from '@angular/common/http'
import { Observable, of } from 'rxjs'
import { catchError, tap } from 'rxjs/operators'

import { JobData, JobPage } from '../models/page/job_page'
import { Job } from '../models/job'

@Injectable()
export class JobService {
  private jobsUrl = '/api/step_flow/jobs'

  constructor(private http: HttpClient) {}

  getJobs(
    page: number,
    per_page: number,
    workflow_id: number,
    step_id: number,
    job_type: string,
  ): Observable<JobPage> {
    let params = new HttpParams()
    if (per_page !== undefined) {
      params = params.append('size', String(per_page))
    }
    if (page > 0) {
      params = params.append('page', String(page + 1))
    }
    if (workflow_id !== undefined) {
      params = params.append('workflow_id', String(workflow_id))
    }
    if (step_id !== undefined) {
      params = params.append('step_id', String(step_id))
    }
    if (job_type !== undefined) {
      params = params.append('job_type', job_type)
    }

    return this.http.get<JobPage>(this.jobsUrl, { params: params }).pipe(
      tap((_jobPage) => this.log('fetched JobPage')),
      catchError(this.handleError('getJobs', undefined)),
    )
  }

  getJob(id: number): Observable<JobData> {
    return this.http.get<JobData>(this.jobsUrl + '/' + id).pipe(
      tap((_job) => this.log('fetched Job')),
      catchError(this.handleError('getJob', undefined)),
    )
  }

  private handleError<T>(operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`)
      return of(result as T)
    }
  }

  private log(message: string) {
    console.log('JobService: ' + message)
  }
}
