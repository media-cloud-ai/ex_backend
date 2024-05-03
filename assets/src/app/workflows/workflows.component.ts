import moment = require('moment')

import { formatDate } from '@angular/common'
import { Component } from '@angular/core'
import { ActivatedRoute, Router } from '@angular/router'
import { Subscription } from 'rxjs'

import { SocketService } from '../services/socket.service'
import { UserPage } from '../models/page/user_page'
import { UserService } from '../services/user.service'
import { WorkflowService } from '../services/workflow.service'
import { WorkflowDurations } from '../models/statistics/duration'
import {
  ViewOption,
  ViewOptionEvent,
  WorkflowPage,
  WorkflowQueryParams,
} from '../models/page/workflow_page'
import { Message } from '../models/message'
import { User } from '../models/user'

@Component({
  selector: 'workflows-component',
  templateUrl: 'workflows.component.html',
  styleUrls: ['./workflows.component.less'],
})
export class WorkflowsComponent {
  private readonly subscriptions = new Subscription()

  length = 1000
  pageIndex = 0
  pageSize = 10
  pageSizeOptions = [10, 20, 50, 100]

  parameters: WorkflowQueryParams
  loading = true

  workflows: WorkflowPage
  durations: WorkflowDurations
  users: UserPage

  // Set to true when a workflow is added or deleted. In this case we need to fetch all workflows on the server when refreshing
  fullReload = false
  workflowsToRefresh: Set<number> = new Set<number>()

  interval: any

  constructor(
    private socketService: SocketService,
    private workflowService: WorkflowService,
    private userService: UserService,
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
      headers: [
        'identifier',
        'reference',
        'created_at',
        'duration',
        'ended_at',
        'launched_by',
      ],
      detailed: false,
      refresh_interval: -1,
      time_interval: 1,
    }

    // Parse all parameters in URL to apply filters
    this.route.queryParamMap.subscribe((params) => {
      this.parameters.mode =
        params.getAll('mode').length > 0
          ? params.getAll('mode')
          : ['file', 'live']
      this.parameters.status = params.getAll('status')
      this.parameters.identifiers = params.getAll('identifiers')
      this.parameters.search = params.getAll('search').toString() || undefined
      this.parameters.headers =
        params.getAll('headers').length > 0
          ? params.getAll('headers')
          : [
              'identifier',
              'reference',
              'created_at',
              'duration',
              'ended_at',
              'launched_by',
            ]
      this.parameters.selectedDateRange.startDate =
        params.get('start_date') != undefined
          ? moment(params.get('start_date'), moment.ISO_8601).toDate()
          : yesterday
      this.parameters.selectedDateRange.endDate =
        params.get('end_date') != undefined
          ? moment(params.get('end_date'), moment.ISO_8601).toDate()
          : today
      this.parameters.refresh_interval =
        params.get('refresh') != undefined
          ? parseInt(params.get('refresh'))
          : -1
    })

    this.route.queryParams.subscribe((params) => {
      this.pageIndex = +params['page'] || 0
      this.pageSize = +params['per_page'] || 10
    })

    this.initSocketService()

    if (this.parameters.refresh_interval !== -1) {
      this.interval = setInterval(() => {
        this.reloadWorkflowsView()
      }, this.parameters.refresh_interval * 1000)
    }
  }

  ngOnDestroy() {
    clearInterval(this.interval)
    this.subscriptions.unsubscribe()
  }

  private initSocketService() {
    /*
      We listen for delete or create worflow's event and set full reload to true to refresh the full list on the refresh interval
    */
    this.socketService.initSocket()
    this.socketService.connectToChannel('notifications:all')

    this.subscriptions.add(
      this.socketService.onNewWorkflow().subscribe((_message: Message) => {
        this.fullReload = true
      }),
    )

    this.subscriptions.add(
      this.socketService.onDeleteWorkflow().subscribe((_message: Message) => {
        this.fullReload = true
      }),
    )
  }

  private trackWorkflow(_index, workflow) {
    return workflow ? workflow.id : undefined
  }

  getWorkflows() {
    this.loading = true
    this.router.navigate(['/workflows'], {
      queryParams: this.getQueryParamsForWorkflows(),
    })

    this.workflowService
      .getWorkflows(this.pageIndex, this.pageSize, this.parameters)
      .subscribe((workflowPage) => {
        this.userService.getAllUsers().subscribe((users) => {
          this.users = users
          this.workflows = this.patchUsernameToWorkflows(workflowPage)
          this.length = workflowPage.total
          this.loading = false

          for (const workflow of this.workflows.data) {
            this.subscriptions.add(
              this.socketService
                .onWorkflowUpdate(workflow.id)
                .subscribe((_message: Message) => {
                  this.workflowsToRefresh.add(workflow.id) // Data will be fetched on refresh
                }),
            )
          }
        })
      })
  }

  private patchUsernameToWorkflows(workflowPage: WorkflowPage): WorkflowPage {
    const users = this.users.data
    workflowPage.data.forEach(function (part, _index) {
      const user = users.find((element: User) => element.uuid == part.user_uuid)
      if (user) {
        part.user = user
      }
    })
    return workflowPage
  }

  getQueryParamsForWorkflows(): Record<string, unknown> {
    const params = {}

    if (this.parameters.identifiers.length > 0)
      params['identifiers'] = this.parameters.identifiers
    if (this.parameters.status.length > 0)
      params['status'] = this.parameters.status
    if (this.parameters.mode.length > 0) params['mode'] = this.parameters.mode
    if (this.parameters.search !== '' && this.parameters.search !== undefined)
      params['search'] = this.parameters.search
    if (this.parameters.refresh_interval != -1)
      params['refresh'] = this.parameters.refresh_interval
    if (this.parameters.headers.length > 0) {
      params['headers'] = this.parameters.headers
    } else {
      params['headers'] = 'none'
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
    this.pageSize = event.pageSize
    this.pageIndex = event.pageIndex
    this.getWorkflows()
  }

  viewOptionsEvent(view_options: ViewOptionEvent) {
    // Trigger detailed view to expand workflow's steps
    if (view_options.option == ViewOption.Detailed) {
      this.parameters.detailed = view_options.value
    }

    // Trigger auto refresh configured by the user
    if (view_options.option == ViewOption.RefreshInterval) {
      clearInterval(this.interval)
      if (view_options.value !== -1) {
        this.interval = setInterval(() => {
          this.reloadWorkflowsView()
        }, view_options.value * 1000)
      }
    }
  }

  reloadWorkflowsView() {
    if (this.fullReload) {
      this.getWorkflows()
      this.fullReload = false
    } else if (this.workflowsToRefresh.size > 0) {
      this.workflowsToRefresh.forEach((w_id) => {
        this.fetchWorkflowInformation(w_id)
      })
      this.workflowsToRefresh.clear()
    }
  }

  private fetchWorkflowInformation(workflow_id) {
    this.workflowService.getWorkflow(workflow_id).subscribe((workflowData) => {
      for (let i = 0; i < this.workflows.data.length; i++) {
        if (this.workflows.data[i].id === workflowData.data.id) {
          this.workflows.data[i] = workflowData.data
        }
      }
    })
    return
  }

  updateSearch(parameters: WorkflowQueryParams) {
    this.parameters = parameters
    this.getWorkflows()
  }
}
