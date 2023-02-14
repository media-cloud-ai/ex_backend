import { Component } from '@angular/core'
import { ActivatedRoute, Router } from '@angular/router'

import { MatDialog } from '@angular/material/dialog'

import { JobService } from '../../services/job.service'
import { Job } from '../../models/job'
import { Message } from '../../models/message'
import { SocketService } from '../../services/socket.service'
import { UserService } from '../../services/user.service'
import { WorkflowService } from '../../services/workflow.service'
import { Workflow } from '../../models/workflow'
import { WorkflowRenderer } from '../../models/workflow_renderer'
import { Subscription } from 'rxjs'

@Component({
  selector: 'workflow-details-component',
  templateUrl: 'workflow_details.component.html',
  styleUrls: ['./workflow_details.component.less'],
})
export class WorkflowDetailsComponent {
  private readonly subscriptions = new Subscription()

  workflow_id: number
  workflow: Workflow
  parent_job: Job
  parent_workflow: Workflow
  renderer: WorkflowRenderer

  parameters_opened = false
  notification_hooks_opened = false

  step_focus: Map<number, boolean> = new Map()
  first_name: string
  last_name: string
  user_name: string

  pause_post_action: any

  constructor(
    private socketService: SocketService,
    private userService: UserService,
    private workflowService: WorkflowService,
    private jobService: JobService,
    private route: ActivatedRoute,
    private router: Router,
    public dialog: MatDialog,
  ) {}

  ngOnInit() {
    this.subscriptions.add(
      this.route.params.subscribe((params) => {
        this.workflow_id = +params['id']
        this.getWorkflow(this.workflow_id)
      }),
    )

    this.socketService.initSocket()
    this.socketService.connectToChannel('notifications:all')

    this.subscriptions.add(
      this.socketService
        .onWorkflowUpdate(this.workflow_id)
        .subscribe((_message: Message) => {
          this.getWorkflow(this.workflow_id)
        }),
    )

    this.subscriptions.add(
      this.socketService.onRetryJob().subscribe((message: Message) => {
        if (message.workflow_id == this.workflow_id) {
          this.getWorkflow(this.workflow_id)
        }
      }),
    )
  }

  ngOnDestroy() {
    this.subscriptions.unsubscribe()
  }

  getWorkflow(workflow_id): void {
    this.workflowService.getWorkflow(workflow_id).subscribe((workflow) => {
      if (workflow === undefined) {
        this.workflow = undefined
        this.renderer = undefined
        return
      }

      if (workflow.data.parent_id != null) {
        this.jobService.getJob(workflow.data.parent_id).subscribe((job) => {
          this.parent_job = job.data
          this.workflowService
            .getWorkflow(this.parent_job.workflow_id)
            .subscribe((parent_workflow) => {
              this.parent_workflow = parent_workflow.data
              this.renderWorkflow(workflow)
            })
        })
      } else {
        this.renderWorkflow(workflow)
      }
    })
  }

  renderWorkflow(workflow) {
    this.workflow = Object.assign(new Workflow(), workflow.data)
    this.renderer = new WorkflowRenderer(this.workflow.steps)
    this.renderer.setStepFocus(this.step_focus)

    this.pause_post_action = this.getPausePostAction()

    this.userService
      .getUserByUuid(this.workflow.user_uuid)
      .subscribe((response) => {
        this.user_name = response.data.email
        if (response.data.first_name && response.data.last_name) {
          this.first_name = response.data.first_name
          this.last_name = response.data.last_name
          this.user_name = response.data.username
        }
      })
  }

  getStepsCount(): string {
    let count = 0
    for (const step of this.workflow.steps) {
      if (
        step.jobs.skipped > 0 ||
        step.jobs.completed > 0 ||
        step.jobs.errors > 0
      ) {
        count++
      }
    }
    return count.toString()
  }

  getTotalSteps(): number {
    return this.workflow.steps.length
  }

  getPausePostAction(): string {
    // Retrieve pause post-action
    if (this.workflow.status.state == 'paused') {
      return this.workflow.status.description
    }
    return undefined
  }

  toggleParameters() {
    this.parameters_opened = !this.parameters_opened
  }

  toggleNotificationHooks() {
    this.notification_hooks_opened = !this.notification_hooks_opened
  }

  updateStepInWorkflow(step) {
    this.step_focus.set(step.id, step.focus)
  }

  refreshWorkflow(event: string) {
    // Other cases will be handled through websockets
    if (event === 'delete') {
      this.router.navigate(['/workflows/']).then((_page) => {
        window.location.reload()
      })
    }
  }
}
