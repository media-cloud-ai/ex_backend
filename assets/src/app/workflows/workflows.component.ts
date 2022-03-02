
import { Component, ViewChild } from '@angular/core'
import { PageEvent } from '@angular/material/paginator'
import { ActivatedRoute, Router } from '@angular/router'

import { Message } from '../models/message'
import { SocketService } from '../services/socket.service'
import { WorkflowService } from '../services/workflow.service'
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
  pageSizeOptions = [
    10,
    20,
    50,
    100
  ]
  video_id: string

  parameters: WorkflowQueryParams

  sub = undefined
  loading = true
  detailed = false

  selectedModes = []

  modes = [
    {id: 'live', label: 'Live'},
    {id: 'file', label: 'File'},
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
  ) {
    let today = new Date();
    let yesterday = new Date();
    yesterday.setDate(today.getDate() - 1);
    this.parameters =  {
      identifiers: [],
      start_date: yesterday,
      end_date: today,
      mode: [
       "file",
       "live"
      ],
      search: undefined,
      status: [],
      detailed: false,
      time_interval: 1
    };
  }

  ngOnInit() {
    this.sub = this.route
      .queryParams
      .subscribe(params => {
        this.page = +params['page'] || 0
        this.pageSize = +params['per_page'] || 10
        this.getWorkflows(this.page, this.pageSize, this.parameters)

        this.socketService.initSocket()
        this.socketService.connectToChannel('notifications:all')

        this.connection = this.socketService.onNewWorkflow()
          .subscribe((message: Message) => {
            this.getWorkflows(this.page, this.pageSize, this.parameters)
          })
        this.connection = this.socketService.onDeleteWorkflow()
          .subscribe((message: Message) => {
            this.getWorkflows(this.page, this.pageSize, this.parameters)
          })
        this.connection = this.socketService.onRetryJob()
          .subscribe((message: Message) => {
            this.getWorkflows(this.page, this.pageSize, this.parameters)
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

  getWorkflows(page: number, pageSize: number, parameters: WorkflowQueryParams) {
    this.workflowService.getWorkflows(
      page,
      pageSize,
      parameters
    ).subscribe(workflowPage => {
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

  changeWorkflowPage(event) {
    this.getWorkflows(event.pageIndex, event.pageSize, this.parameters)
  }

  toogleDetailed(detailed: boolean) {
    this.parameters.detailed = detailed
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

  updateWorkflows(parameters: WorkflowQueryParams) {
    this.getWorkflows(this.page, this.pageSize, this.parameters)
  }
}
