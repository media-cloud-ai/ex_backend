
import {Component} from '@angular/core'
import {ActivatedRoute, Router} from '@angular/router'

import {SocketService} from '../services/socket.service'
import {WorkflowService} from '../services/workflow.service'
import {WorkflowPage} from '../models/page/workflow_page'
import {Workflow} from '../models/workflow'

@Component({
  selector: 'orders-component',
  templateUrl: 'orders.component.html',
  styleUrls: ['./orders.component.less'],
})

export class OrdersComponent {
  sub = undefined
  loading = true
  page = 0
  pageSize = 10
  length = 1000
  pageSizeOptions = [
    10,
    20,
    50,
    100
  ]
  reference: string
  after_date: undefined
  before_date: undefined

  selectedStatus = [
    'completed',
    'error',
    'processing',
  ]
  selectedWorkflows = [
    'FranceTélévisions ACS (standalone)'
  ]
  workflows: WorkflowPage
  connections: any = []

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private socketService: SocketService,
    private workflowService: WorkflowService,
  ) {}

  ngOnInit() {
    this.sub = this.route
      .queryParams
      .subscribe(params => {
        this.page = +params['page'] || 0
        this.pageSize = +params['per_page'] || 10
        this.reference = params['reference']
        this.getWorkflows(this.page)

        this.socketService.initSocket()
        this.socketService.connectToChannel('notifications:all')
      })
  }

  ngOnDestroy() {
    if (this.sub) {
      this.sub.unsubscribe()
    }
  }

  newOrder() {
    this.router.navigate(['/orders/new'])
  }

  getWorkflows(index) {
    console.log("get WFs")
    for (let connection of this.connections) {
      connection.unsubscribe()
    }
    this.loading = true
    this.workflowService.getWorkflows(
      index,
      this.pageSize,
      this.reference,
      this.selectedStatus,
      this.selectedWorkflows,
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
          .subscribe((message) => {
            this.updateWorkflow(message.body.workflow_id)
          })
      }
    })
  }

  eventGetWorkflows(event) {
    this.pageSize = event.pageSize
    this.router.navigate(['/orders'], { queryParams: this.getQueryParamsForPage(event.pageIndex, event.pageSize) })
    this.getWorkflows(event.pageIndex)
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
    if (this.reference !== '') {
      params['reference'] = this.reference
    }
    if (this.selectedStatus.length != 3) {
      params['status[]'] = this.selectedStatus
    }
    if (this.selectedWorkflows.length !== 4) {
      params['workflows[]'] = this.selectedWorkflows
    }

    return params
  }
}
