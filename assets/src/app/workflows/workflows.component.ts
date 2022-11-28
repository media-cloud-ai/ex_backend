import moment = require('moment')

import { formatDate } from '@angular/common'
import { Component } from '@angular/core'
import { PageEvent } from '@angular/material/paginator'
import { ActivatedRoute, Router } from '@angular/router'

import { Message } from '../models/message'
import { SocketService } from '../services/socket.service'
import { WorkflowService } from '../services/workflow.service'
import { StatisticsService } from '../services/statistics.service'
import { WorkflowDurations } from '../models/statistics/duration'
import { WorkflowPage } from '../models/page/workflow_page'
import { WorkflowQueryParams } from '../models/page/workflow_page'

@Component({
  selector: 'workflows-component',
  templateUrl: 'workflows.component.html',
  styleUrls: ['./workflows.component.less'],
})
export class WorkflowsComponent {
  length = 1000
  page = 0
  pageSize = 10
  pageSizeOptions = [10, 20, 50, 100]
  video_id: string

  parameters: WorkflowQueryParams

  sub = undefined
  loading = true
  detailed = false

  selectedModes = []

  modes = [
    { id: 'live', label: 'Live' },
    { id: 'file', label: 'File' },
  ]

  pageEvent: PageEvent
  workflows: WorkflowPage
  durations: WorkflowDurations
  connection: any
  connections: any = []
  messages: Message[] = []

  constructor(
    private socketService: SocketService,
    private workflowService: WorkflowService,
    private statisticsService: StatisticsService,
    private route: ActivatedRoute,
    private router: Router,
  ) {}

  ngOnInit() {
    const today = new Date()
    const yesterday = new Date()
    yesterday.setDate(today.getDate() - 1)

    this.parameters = {
      identifiers: [],
      selectedDateRange: {
        startDate: yesterday,
        endDate: today,
      },
      mode: ['file', 'live'],
      search: undefined,
      status: [],
      detailed: false,
      time_interval: 1,
    }

    this.route.queryParamMap.subscribe((params) => {
      this.parameters.mode =
        params.getAll('mode').length > 0
          ? params.getAll('mode')
          : ['file', 'live']
      this.parameters.status = params.getAll('status')
      this.parameters.identifiers = params.getAll('identifiers')
      this.parameters.search = params.getAll('search').toString() || undefined
      this.parameters.selectedDateRange.startDate =
        params.get('start_date') != undefined
          ? moment(params.get('start_date'), moment.ISO_8601).toDate()
          : yesterday
      this.parameters.selectedDateRange.endDate =
        params.get('end_date') != undefined
          ? moment(params.get('end_date'), moment.ISO_8601).toDate()
          : today
    })

    this.sub = this.route.queryParams.subscribe((params) => {
      this.page = +params['page'] || 0
      this.pageSize = +params['per_page'] || 10

      this.socketService.initSocket()
      this.socketService.connectToChannel('notifications:all')

      this.connection = this.socketService
        .onNewWorkflow()
        .subscribe((_message: Message) => {
          this.getWorkflows(this.page, this.pageSize, this.parameters)
        })
      this.connection = this.socketService
        .onDeleteWorkflow()
        .subscribe((_message: Message) => {
          this.getWorkflows(this.page, this.pageSize, this.parameters)
        })
      this.connection = this.socketService
        .onRetryJob()
        .subscribe((_message: Message) => {
          this.getWorkflows(this.page, this.pageSize, this.parameters)
        })
    })
  }

  ngOnDestroy() {
    if (this.sub) {
      this.sub.unsubscribe()
    }
    for (const connection of this.connections) {
      connection.unsubscribe()
    }
  }

  getWorkflows(
    page: number,
    pageSize: number,
    parameters: WorkflowQueryParams,
  ) {
    this.eventGetWorkflows()

    this.workflowService
      .getWorkflows(page, pageSize, parameters)
      .subscribe((workflowPage) => {
        if (workflowPage === undefined) {
          this.length = undefined
          this.workflows = new WorkflowPage()
          return
        }

        this.workflows = workflowPage
        this.length = workflowPage.total
        this.loading = false
        for (const workflow of this.workflows.data) {
          const _connection = this.socketService
            .onWorkflowUpdate(workflow.id)
            .subscribe((message: Message) => {
              this.updateWorkflow(message.body.workflow_id)
            })
        }

        const workflow_ids = this.workflows.data.map((workflow) => workflow.id)
        this.statisticsService
          .getWorkflowsDurations(workflow_ids)
          .subscribe((response) => {
            this.durations = response
          })
      })
  }

  eventGetWorkflows(): void {
    this.router.navigate(['/workflows'], {
      queryParams: this.getQueryParamsForWorkflows(),
    })
  }

  getQueryParamsForWorkflows(): Record<string, unknown> {
    const params = {}

    if (this.parameters.identifiers.length > 0) {
      params['identifiers'] = this.parameters.identifiers
    }

    if (this.parameters.status.length > 0) {
      params['status'] = this.parameters.status
    }

    if (this.parameters.mode.length > 0) {
      params['mode'] = this.parameters.mode
    }

    if (this.parameters.search !== '' && this.parameters.search !== undefined) {
      params['search'] = this.parameters.search
    }

    params['start_date'] = formatDate(
      this.parameters.selectedDateRange.startDate,
      'yyyy-MM-ddTHH:mm:ss',
      'fr',
    )
    params['end_date'] = formatDate(
      this.parameters.selectedDateRange.endDate,
      'yyyy-MM-ddTHH:mm:ss',
      'fr',
    )
    return params
  }

  changeWorkflowPage(event) {
    this.getWorkflows(event.pageIndex, event.pageSize, this.parameters)
  }

  toogleDetailed(detailed: boolean) {
    this.parameters.detailed = detailed
  }

  updateWorkflow(workflow_id) {
    this.workflowService.getWorkflow(workflow_id).subscribe((workflowData) => {
      for (let i = 0; i < this.workflows.data.length; i++) {
        if (this.workflows.data[i].id === workflowData.data.id) {
          this.statisticsService
            .getWorkflowDurations(workflow_id)
            .subscribe((response) => {
              for (let j = 0; j < this.durations.data.length; j++) {
                if (
                  this.durations.data[j].workflow_id ===
                  response.data[0].workflow_id
                ) {
                  this.durations.data[j] = response.data[0]
                  this.workflows.data[i] = workflowData.data
                  return
                }
              }
            })
          return
        }
      }
    })
  }

  private getWorkflowDuration(workflow_id) {
    return this.durations.data.find(
      (duration) => duration.workflow_id == workflow_id,
    )
  }

  updateWorkflows(parameters: WorkflowQueryParams) {
    this.parameters = parameters
    this.getWorkflows(this.page, this.pageSize, this.parameters)
  }
}
