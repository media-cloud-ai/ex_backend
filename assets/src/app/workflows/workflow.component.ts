import { Component, EventEmitter, Input, Output } from '@angular/core'
import { MatDialog } from '@angular/material/dialog'
import { Router } from '@angular/router'
import { Subscription } from 'rxjs'

import { AuthService } from '../authentication/auth.service'
import { UserService } from '../services/user.service'
import { WorkflowService } from '../services/workflow.service'
import { Workflow } from '../models/workflow'
import { WorkflowActionsDialogComponent } from './dialogs/workflow_actions_dialog.component'
import { WorkflowPauseDialogComponent } from './dialogs/workflow_pause_dialog.component'
import { MatSnackBar } from '@angular/material/snack-bar'

@Component({
  selector: 'workflow-component',
  templateUrl: 'workflow.component.html',
  styleUrls: ['./workflow.component.less'],
})
export class WorkflowComponent {
  private readonly subscriptions = new Subscription()

  @Input() workflow: Workflow
  @Input() detailed = false

  // This refreshEvent allows direct refresh when modifying a workflow through the page
  @Output() refreshEvent = new EventEmitter()

  first_name: string
  last_name: string
  user_name: string

  can_stop = false
  can_pause = false
  can_resume = false
  can_delete = false

  right_stop = false
  right_retry = false
  right_delete = false
  right_duplicate = false

  constructor(
    private authService: AuthService,
    private router: Router,
    private userService: UserService,
    private snackBar: MatSnackBar,
    private workflowService: WorkflowService,
    public dialog: MatDialog,
  ) {}

  ngOnChanges() {
    this.workflow = Object.assign(new Workflow(), this.workflow)
  }

  ngOnInit() {
    this.workflow = Object.assign(new Workflow(), this.workflow)
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

  onMoreActionsToggle() {
    this.can_stop = this.workflow.can_stop()
    this.can_pause = this.workflow.can_pause()
    this.can_resume = this.workflow.can_resume()
    this.can_delete = this.workflow.can_delete()

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

    this.authService
      .hasAnyRights('workflow::' + this.workflow.identifier, 'create')
      .subscribe((response) => {
        this.right_duplicate = response.authorized
      })
  }

  switchDetailed(): void {
    this.detailed = !this.detailed
    if (this.workflow !== undefined && this.detailed) {
      this.authService
        .hasAnyRights('workflow::' + this.workflow.identifier, 'retry')
        .subscribe((response) => {
          this.right_retry = response.authorized
        })
    }
  }

  getStepsCount(): number {
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
    return count
  }

  getTotalSteps(): number {
    return this.workflow.steps.length
  }

  pause(): void {
    const dialogRef = this.dialog.open(WorkflowPauseDialogComponent, {
      data: {
        workflow: this.workflow,
      },
    })

    dialogRef.afterClosed().subscribe((user_choice) => {
      if (user_choice !== undefined && this.workflow.can_pause()) {
        this.workflowService
          .sendWorkflowEvent(user_choice.workflow.id, user_choice.event)
          .subscribe((response) => {
            console.log(response)
            this.refreshEvent.emit()
          })
      }
    })
  }

  resume(): void {
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
            this.refreshEvent.emit()
          })
      }
    })
  }

  stop(): void {
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
            this.refreshEvent.emit()
          })
      }
    })
  }

  delete(): void {
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
            this.refreshEvent.emit()
          })
      }
    })
  }

  duplicate(): void {
    if (this.right_duplicate) {
      const duplicate_parameters =
        this.workflowService.getCreateWorkflowParameters(this.workflow)
      this.workflowService
        .createWorkflow(duplicate_parameters)
        .subscribe((response) => {
          if (response) {
            console.log(response)
            this.router
              .navigate(['/workflows/' + response.data.id])
              .then((_page) => {
                window.location.reload()
              })
          } else {
            const _snackBarRef = this.snackBar.open(
              'The workflow definition is not defined!',
              '',
              {
                duration: 1000,
              },
            )
          }
        })
    }
  }
}
