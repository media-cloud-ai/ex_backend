
import {Component, ViewChild} from '@angular/core'
import {PageEvent} from '@angular/material/paginator'
import {ActivatedRoute, Router} from '@angular/router'

import {Message} from '../models/message'
import {SocketService} from '../services/socket.service'
import {WorkflowService} from '../services/workflow.service'
import {WorkflowPage} from '../models/page/workflow_page'
import {Workflow} from '../models/workflow'

import * as moment from 'moment'

@Component({
  selector: 'workflows-component',
  templateUrl: 'workflows.component.html',
  styleUrls: ['./workflows.component.less'],
})

export class WorkflowsComponent {
  length = 1000
  pageSize = 10
  pageSizeOptions = [
    10,
    20,
    50,
    100
  ]
  video_id: string
  after_date: undefined
  before_date: undefined
  page = 0
  sub = undefined
  loading = true
  detailed = false

  selectedStatus = [
    'completed',
    'error',
    'processing',
  ]

  selectedModes = []
  selectedWorkflows = []

  status = [
    {id: 'completed', label: 'Completed'},
    {id: 'error', label: 'Error'},
    {id: 'processing', label: 'Processing'},
  ]

  modes = [
    {id: 'live', label: 'Live'},
    {id: 'file', label: 'File'},
  ]

  workflow_ids = [
    {id: 'FranceTV Studio Ingest Rosetta', label: 'FranceTV Studio Ingest Rosetta'},
    {id: 'FranceTélévisions Rdf Ingest', label: 'FranceTélévisions Rdf Ingest'},
    {id: 'FranceTélévisions ACS', label: 'FranceTélévisions ACS'},
    {id: 'FranceTélévisions Dash Ingest', label: 'FranceTélévisions Dash Ingest'},
    {id: 'FranceTélévisions ACS (standalone)', label: 'FranceTélévisions ACS (standalone)'},
  ]

  pageEvent: PageEvent
  workflows: WorkflowPage
  connection: any
  connections: any = []
  messages: Message[] = []

  constructor(
    private socketService: SocketService,
    private workflowService: WorkflowService,
    private route: ActivatedRoute,
    private router: Router
  ) {}

  ngOnInit() {
    this.sub = this.route
      .queryParams
      .subscribe(params => {
        this.page = +params['page'] || 0
        this.pageSize = +params['per_page'] || 10
        this.video_id = params['video_id']
        this.detailed = 'detailed' in params

        var status = params['status[]']
        if (status && !Array.isArray(status)){
          status = [status]
        }
        if (status) {
          this.selectedStatus = status
        }
        var workflows = params['workflows[]']
        if (workflows && !Array.isArray(workflows)){
          workflows = [workflows]
        }
        if (workflows) {
          this.selectedWorkflows = workflows
        }
        this.getWorkflows(this.page)

        this.socketService.initSocket()
        this.socketService.connectToChannel('notifications:all')

        this.connection = this.socketService.onNewWorkflow()
          .subscribe((message: Message) => {
            this.getWorkflows(this.page)
          })
        this.connection = this.socketService.onDeleteWorkflow()
          .subscribe((message: Message) => {
            this.getWorkflows(this.page)
          })
        this.connection = this.socketService.onRetryJob()
          .subscribe((message: Message) => {
            this.getWorkflows(this.page)
          })
      })
  }

  ngOnDestroy() {
    if (this.sub) {
      this.sub.unsubscribe()
    }
    for (let connection of this.connections) {
      connection.unsubscribe()
    }
  }

  getWorkflows(index) {
    for (let connection of this.connections) {
      connection.unsubscribe()
    }
    this.loading = true
    this.workflowService.getWorkflows(
      index,
      this.pageSize,
      this.video_id,
      this.selectedStatus,
      this.selectedModes,
      this.selectedWorkflows,
      [],
      this.after_date,
      this.before_date)
    .subscribe(workflowPage => {
      if (workflowPage === undefined) {
        this.length = undefined
        this.workflows = new WorkflowPage()
        return
      }

      this.workflows = workflowPage
      this.length = workflowPage.total
      this.loading = false
      for (let workflow of this.workflows.data) {
        var connection = this.socketService.onWorkflowUpdate(workflow.id)
          .subscribe((message: Message) => {
            this.updateWorkflow(message.body.workflow_id)
          })
      }
    })
  }

  eventGetWorkflows(event) {
    this.pageSize = event.pageSize
    this.router.navigate(['/workflows'], { queryParams: this.getQueryParamsForPage(event.pageIndex, event.pageSize) })
    this.getWorkflows(event.pageIndex)
  }

  updateWorkflows() {
    this.router.navigate(['/workflows'], { queryParams: this.getQueryParamsForPage(0) })
    this.getWorkflows(0)
  }

  updateSearch() {
    this.router.navigate(['/workflows'], {
      queryParams: this.getQueryParamsForPage(
        this.page,
        this.pageSize)
    })
    this.getWorkflows(0)
  }

  updateWorkflow(workflow_id) {
    this.workflowService.getWorkflow(workflow_id)
    .subscribe(workflowData => {
      for (let i = 0; i < this.workflows.data.length; i++) {
        if (this.workflows.data[i].id === workflowData.data.id) {
          this.workflows.data[i] = workflowData.data
          return
        }
      }
    })
  }

  getQueryParamsForPage(pageIndex: number, pageSize: number = undefined): Object {
    var params = {}
    if (pageIndex !== 0) {
      params['page'] = pageIndex
    }
    if (pageSize) {
      if (pageSize !== 10) {
        params['per_page'] = pageSize
      }
    } else {
      if (this.pageSize !== 10) {
        params['per_page'] = this.pageSize
      }
    }
    if (this.video_id !== '') {
      params['video_id'] = this.video_id
    }
    if (this.selectedStatus.length != 3) {
      params['status[]'] = this.selectedStatus
    }
    if (this.selectedWorkflows.length !== 4) {
      params['workflows[]'] = this.selectedWorkflows
    }
    if (this.detailed) {
      params['detailed'] = true
    }

    return params
  }
}
