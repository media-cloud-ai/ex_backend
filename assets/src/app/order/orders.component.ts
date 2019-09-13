
import {Component} from '@angular/core'
import {ActivatedRoute, Router} from '@angular/router'

// import {OrderService} from '../services/order.service'
import {Message} from '../models/message'
import {SocketService} from '../services/socket.service'
import {WorkflowService} from '../services/workflow.service'
import {WorkflowPage} from '../models/page/workflow_page'
import {WorkflowComponent} from '../workflows/workflow.component'

import * as moment from 'moment'

@Component({
  selector: 'orders-component',
  templateUrl: 'orders.component.html',
  styleUrls: ['./orders.component.less'],
})

export class OrdersComponent {
  order: any

  workflows: WorkflowPage
  loading = true
  page = 0
  pageSize = 10
  pageSizeOptions = [
    10,
    20,
    50,
    100
  ]
  length = 1000

  selectedStatus = [
    'completed',
    'error',
    'processing',
  ]

  selectedWorkflows = [
    'FranceTélévisions ACS (standalone)'
  ]

  workflow_ids = [
    {id: 'FranceTélévisions ACS (standalone)', label: 'FranceTélévisions ACS (standalone)'},
  ]

  constructor(
    private router: Router,
    private socketService: SocketService,
    private workflowService: WorkflowService,
    // private orderService: OrderService
  ) {}

  ngOnInit() {
    // this.order.getOrders()
    // .subscribe(response => {
    //   this.order = response
    // })
    this.getWorkflows(this.page);
  }

  newOrder() {
    this.router.navigate(['/orders/new'])
  }

   getWorkflows(index) {
    console.log("get WFs")
    this.loading = true
    this.workflowService.getWorkflows(
      index,
      this.pageSize,
      undefined,
      this.selectedStatus,
      this.selectedWorkflows,
      undefined,
      undefined)
    .subscribe(workflowPage => {
      if (workflowPage === undefined) {
        this.length = undefined
        this.workflows = new WorkflowPage()
        return
      }

      this.workflows = workflowPage
      console.log("this.workflows: ", this.workflows);
      this.length = workflowPage.total
      this.loading = false
      // for (let workflow of this.workflows.data) {
      //   var connection = this.socketService.onWorkflowUpdate(workflow.id)
      //     .subscribe((message: Message) => {
      //       this.updateWorkflow(message.body.workflow_id)
      //     })
      // }
    })
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

  // This is a copy paste of the AppModule.DurationComponent...
  getWorkflowDuration(workflow) {
    if (workflow.artifacts[0]) {
      let start_moment = moment(workflow.created_at)
      let end_moment = moment(workflow.artifacts[0]['inserted_at'])
      return end_moment.diff(start_moment)
    } else {
      return undefined
    }
  }

  getStepsCount(workflow): number {
    let count = 0
    for (let step of workflow.flow.steps) {
      if (step.jobs.skipped > 0 ||
         step.jobs.completed > 0 ||
         step.jobs.errors > 0) {
        count++
      }
    }
    return count
  }

  getTotalSteps(workflow): number {
    return workflow['flow'].steps.length
  }


}
