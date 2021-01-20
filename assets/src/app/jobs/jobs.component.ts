
import {Component, Input, ViewChild} from '@angular/core'
import {MatDialog} from '@angular/material/dialog'
import {PageEvent} from '@angular/material/paginator'
import {ActivatedRoute, Router} from '@angular/router'

import {AuthService} from '../authentication/auth.service'
import {JobService} from '../services/job.service'
import {WorkflowService} from '../services/workflow.service'
import {JobPage} from '../models/page/job_page'
import {Job} from '../models/job'

import {JobDetailsDialogComponent} from './details/job_details_dialog.component'

import * as moment from 'moment'

@Component({
  selector: 'jobs-component',
  templateUrl: 'jobs.component.html',
  styleUrls: ['./jobs.component.less'],
})

export class JobsComponent {
  length = 1000
  pageSize = 10
  page = 0
  sub = undefined
  job_duration_rendering_mode = 'human'

  @Input() jobType: string
  @Input() step_id: number
  @Input() workflowId: number

  pageEvent: PageEvent
  jobs: JobPage

  right_retry: boolean = false
  is_live: boolean = false

  constructor(
    private authService: AuthService,
    private jobService: JobService,
    private workflowService: WorkflowService,
    private route: ActivatedRoute,
    private router: Router,
    public dialog: MatDialog
  ) {}

  ngOnInit() {
    this.sub = this.route
      .queryParams
      .subscribe(params => {
        this.page = 0
        this.getJobs(this.page)
      })

    this.workflowService.getWorkflow(this.workflowId)
      .subscribe(workflow => {
        if (workflow === undefined) {
          return
        }
        this.is_live = workflow.data.is_live

        let authorized_to_retry = workflow.data.rights.find((r) => r.action === "retry")
        if (authorized_to_retry !== undefined) {
          this.right_retry = this.authService.hasAnyRights(authorized_to_retry.groups)
        }}
    )
  }

  ngOnDestroy() {
    this.sub.unsubscribe()
  }

  getJobs(index) {
    this.jobService.getJobs(index, 200, this.workflowId, this.step_id, this.jobType)
    .subscribe(jobPage => {
      this.jobs = jobPage
      this.length = jobPage.total
    })
  }

  eventGetJobs(event) {
    this.router.navigate(['/jobs'], { queryParams: this.getQueryParamsForPage(event.pageIndex) })
    this.getJobs(event.pageIndex)
  }

  updateJobs() {
    this.router.navigate(['/jobs'], { queryParams: this.getQueryParamsForPage(0) })
    this.getJobs(0)
  }

  getQueryParamsForPage(pageIndex: number): Object {
    var params = {}
    if (pageIndex !== 0) {
      params['page'] = pageIndex
    }
    return params
  }

  switchDurationRenderingMode() {
    if (this.job_duration_rendering_mode === 'human') {
      this.job_duration_rendering_mode = 'timecode_ms'
    } else {
      if (this.job_duration_rendering_mode === 'timecode_ms') {
        this.job_duration_rendering_mode = 'human'
      }
    }
  }

  displayJobDetails(job: Job) {
    this.dialog.open(JobDetailsDialogComponent, { data: job })
  }

  retryJob(job: Job) {
    this.workflowService.sendWorkflowEvent(this.workflowId, {event: 'retry', job_id: job.id})
    .subscribe(response => {
      console.log(response)
    })
  }
}
