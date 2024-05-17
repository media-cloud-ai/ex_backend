import { Component, Input } from '@angular/core'
import { MatDialog } from '@angular/material/dialog'
import { PageEvent } from '@angular/material/paginator'
import { ActivatedRoute, Router } from '@angular/router'

import { AuthService } from '../authentication/auth.service'
import { JobService } from '../services/job.service'
import { WorkflowService } from '../services/workflow.service'
import { JobPage } from '../models/page/job_page'
import { Job } from '../models/job'
import { Workflow } from '../models/workflow'

import { JobDetailsDialogComponent } from './details/job_details_dialog.component'

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
  child_workflow_progression = 0
  child_workflow_buffer = 0

  @Input() jobType: string
  @Input() step_id: number
  @Input() workflow: Workflow

  pageEvent: PageEvent
  jobs: JobPage

  right_retry = false
  is_live = false

  retryable_jobs = ['error', 'stopped'] as const

  constructor(
    private authService: AuthService,
    private jobService: JobService,
    private workflowService: WorkflowService,
    private route: ActivatedRoute,
    private router: Router,
    public dialog: MatDialog,
  ) {}

  ngOnInit() {
    this.sub = this.route.queryParams.subscribe((_params) => {
      this.page = 0
      this.getJobs(this.page)
    })

    this.is_live = this.workflow.is_live

    this.authService
      .hasAnyRights('workflow::' + this.workflow.identifier, ['retry'])
      .subscribe((response) => {
        this.right_retry = response.authorized['retry']
      })
  }

  ngOnDestroy() {
    this.sub.unsubscribe()
  }

  getJobs(index) {
    this.jobService
      .getJobs(index, 200, this.workflow.id, this.step_id, this.jobType)
      .subscribe((jobPage) => {
        this.length = jobPage.total
        this.jobs = {
          data: jobPage.data.map((job) =>
            this.getChildWorkflowProgression(job),
          ),
          total: jobPage.total,
        }
      })
  }

  eventGetJobs(event) {
    this.router.navigate(['/jobs'], {
      queryParams: this.getQueryParamsForPage(event.pageIndex),
    })
    this.getJobs(event.pageIndex)
  }

  updateJobs() {
    this.router.navigate(['/jobs'], {
      queryParams: this.getQueryParamsForPage(0),
    })
    this.getJobs(0)
  }

  getQueryParamsForPage(pageIndex: number): Record<string, unknown> {
    const params = {}
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

  getLastStatusDescription(job: Job) {
    const lastStatus = Job.getLastStatus(job)
    if (lastStatus) {
      return lastStatus['description']
    }
    return undefined
  }

  getChildWorkflowProgression(job: Job) {
    if (job.child_workflow != undefined) {
      this.workflowService
        .getWorkflow(job.child_workflow.id)
        .subscribe((workflow) => {
          const totalSteps = workflow.data.steps?.length
          const completedSteps = workflow.data.steps?.filter(function (step) {
            return step.status == 'completed'
          }).length
          const processingSteps = workflow.data.steps?.filter(function (step) {
            return step.status == 'processing'
          }).length
          job.child_workflow_progressions = {
            progression: Math.round((100 * completedSteps) / totalSteps),
            buffer: Math.round(
              (100 * (completedSteps + processingSteps)) / totalSteps,
            ),
          }
        })
    }
    return job
  }

  displayJobDetails(job: Job, workflow: Workflow) {
    this.dialog.open(JobDetailsDialogComponent, {
      data: { job: job, workflow: workflow },
    })
  }

  retryJob(job: Job) {
    this.workflowService
      .sendWorkflowEvent(this.workflow.id, { event: 'retry', job_id: job.id })
      .subscribe((response) => {
        console.log(response)
        this.ngOnInit()
      })
  }
}
