import { Component, EventEmitter, Input, Output } from '@angular/core'
import { MatDialog } from '@angular/material/dialog'
import { MatSnackBar } from '@angular/material/snack-bar'
import { Router } from '@angular/router'

import { AuthService } from '../../authentication/auth.service'
import { Workflow } from '../../models/workflow'
import { WorkflowActionsDialogComponent } from '../dialogs/workflow_actions_dialog.component'
import { WorkflowPauseDialogComponent } from '../dialogs/workflow_pause_dialog.component'
import { WorkflowService } from '../../services/workflow.service'

@Component({
  selector: 'workflow-actions-component',
  styleUrls: ['./workflow_actions.component.less'],
  templateUrl: 'workflow_actions.component.html',
})
export class WorkflowActionsComponent {
  @Input() workflow: Workflow

  // This refreshEvent allows direct refresh when modifying a workflow through the page
  @Output() refreshEvent = new EventEmitter<string>()

  can_stop = false
  can_pause = false
  can_resume = false
  can_delete = false
  child_workflow = false

  right_stop = false
  right_delete = false
  right_duplicate = false

  constructor(
    private authService: AuthService,
    private router: Router,
    private snackBar: MatSnackBar,
    private workflowService: WorkflowService,
    public dialog: MatDialog,
  ) {}

  onMoreActionsToggle() {
    this.can_stop = this.workflow.can_stop()
    this.can_pause = this.workflow.can_pause()
    this.can_resume = this.workflow.can_resume()
    this.can_delete = this.workflow.can_delete()
    this.child_workflow = this.workflow.parent_id != undefined ? true : false

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
            this.refreshEvent.emit('pause')
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
            this.refreshEvent.emit('resume')
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
            this.refreshEvent.emit('stop')
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
            this.refreshEvent.emit('delete')
          })
      }
    })
  }

  duplicate(): void {
    this.workflowService
      .sendWorkflowEvent(this.workflow.id, { event: 'duplicate' })
      .subscribe((response) => {
        if (response) {
          console.log(response)
          this.router
            .navigate(['/workflows/' + response.workflow_id])
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
