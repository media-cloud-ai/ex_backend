import { Component } from '@angular/core'
import { ActivatedRoute } from '@angular/router'

import { MatDialog } from '@angular/material/dialog'
import { Message } from '../../models/message'
import { AuthService } from '../../authentication/auth.service'
import { SocketService } from '../../services/socket.service'
import { UserService } from '../../services/user.service'
import { WorkflowService } from '../../services/workflow.service'
import { Workflow } from '../../models/workflow'
import { WorkflowRenderer } from '../../models/workflow_renderer'
import { WorkflowActionsDialogComponent } from '../dialogs/workflow_actions_dialog.component'
import { WorkflowPauseDialogComponent } from '../dialogs/workflow_pause_dialog.component'

@Component({
  selector: 'workflow-details-component',
  templateUrl: 'workflow_details.component.html',
  styleUrls: ['./workflow_details.component.less'],
})
export class WorkflowDetailsComponent {
  private sub: any

  workflow_id: number
  workflow: Workflow
  renderer: WorkflowRenderer
  can_stop = false
  can_pause = false
  can_resume = false
  can_delete = false
  parameters_opened = false
  notification_hooks_opened = false
  connection: any
  messages: Message[] = []
  right_stop = false
  right_delete = false
  step_focus: Map<number, boolean> = new Map()
  first_name: string
  last_name: string
  user_name: string

  pause_post_action: any

  constructor(
    private authService: AuthService,
    private socketService: SocketService,
    private userService: UserService,
    private workflowService: WorkflowService,
    private route: ActivatedRoute,
    public dialog: MatDialog,
  ) {}

  ngOnInit() {
    this.sub = this.route.params.subscribe((params) => {
      this.workflow_id = +params['id']
      this.getWorkflow(this.workflow_id)
    })

    this.socketService.initSocket()
    this.socketService.connectToChannel('notifications:all')

    this.connection = this.socketService
      .onWorkflowUpdate(this.workflow_id)
      .subscribe((_message: Message) => {
        this.getWorkflow(this.workflow_id)
      })

    this.connection = this.socketService
      .onRetryJob()
      .subscribe((message: Message) => {
        if (message.workflow_id == this.workflow_id) {
          this.getWorkflow(this.workflow_id)
        }
      })
  }

  ngOnDestroy() {
    this.sub.unsubscribe()
  }

  getWorkflow(workflow_id): void {
    this.workflowService.getWorkflow(workflow_id).subscribe((workflow) => {
      if (workflow === undefined) {
        this.workflow = undefined
        this.renderer = undefined
        return
      }
      this.workflow = Object.assign(new Workflow(), workflow.data)
      this.renderer = new WorkflowRenderer(this.workflow.steps)
      this.renderer.setStepFocus(this.step_focus)

      this.can_stop = this.workflow.can_stop()
      this.can_pause = this.workflow.can_pause()
      this.can_resume = this.workflow.can_resume()
      this.can_delete = this.workflow.can_delete()

      this.pause_post_action = this.getPausePostAction()

      if (this.can_stop) {
        this.authService
          .hasAnyRights('workflow::' + this.workflow.identifier, 'abort')
          .subscribe((response) => {
            this.right_stop = response.authorized
          })
      }

      if (this.can_delete) {
        this.authService
          .hasAnyRights('workflow::' + this.workflow.identifier, 'delete')
          .subscribe((response) => {
            this.right_delete = response.authorized
          })
      }

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

  getPausePostAction(): any {
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

  pause(_workflow_id): void {
    const dialogRef = this.dialog.open(WorkflowPauseDialogComponent, {
      data: {
        workflow: this.workflow,
        message: 'pause',
      },
    })

    dialogRef.afterClosed().subscribe((user_choice) => {
      if (user_choice !== undefined && this.workflow.can_pause()) {
        this.workflowService
          .sendWorkflowEvent(user_choice.workflow.id, user_choice.event)
          .subscribe((response) => {
            console.log(response)
          })
      }
    })
  }

  resume(_workflow_id): void {
    const dialogRef = this.dialog.open(WorkflowActionsDialogComponent, {
      data: {
        workflow: this.workflow,
        message: 'resume',
      },
    })

    dialogRef.afterClosed().subscribe((workflow) => {
      if (workflow !== undefined && this.workflow.can_resume()) {
        console.log('Resume workflow!')
        this.workflowService
          .sendWorkflowEvent(workflow.id, { event: 'resume' })
          .subscribe((response) => {
            console.log(response)
          })
      }
    })
  }

  stop(_workflow_id): void {
    const message = this.workflow.is_live ? 'stop' : 'abort'

    const dialogRef = this.dialog.open(WorkflowActionsDialogComponent, {
      data: {
        workflow: this.workflow,
        message: message,
      },
    })

    dialogRef.afterClosed().subscribe((workflow) => {
      if (workflow !== undefined && this.workflow.can_stop()) {
        console.log('Stop/abort workflow:', message)
        this.workflowService
          .sendWorkflowEvent(workflow.id, { event: message })
          .subscribe((response) => {
            console.log(response)
          })
      }
    })
  }

  delete(_workflow_id): void {
    const dialogRef = this.dialog.open(WorkflowActionsDialogComponent, {
      data: {
        workflow: this.workflow,
        message: 'delete',
      },
    })

    dialogRef.afterClosed().subscribe((workflow) => {
      if (workflow !== undefined && this.workflow.can_delete()) {
        this.workflowService
          .sendWorkflowEvent(workflow.id, { event: 'delete' })
          .subscribe((_response) => {
            window.location.reload()
          })
      }
    })
  }

  updateStepInWorkflow(step) {
    this.step_focus.set(step.id, step.focus)
  }
}
