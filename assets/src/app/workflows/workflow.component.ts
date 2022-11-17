import { Component, Input } from '@angular/core'
import { Router } from '@angular/router'
import { MatDialog } from '@angular/material/dialog'

import { AuthService } from '../authentication/auth.service'
import { StartWorkflowDefinition } from '../models/startWorkflowDefinition'
import { UserService } from '../services/user.service'
import { WorkflowService } from '../services/workflow.service'
import { Workflow } from '../models/workflow'
import { WorkflowDuration } from '../models/statistics/duration'
import { WorkflowActionsDialogComponent } from './dialogs/workflow_actions_dialog.component'
import { WorkflowPauseDialogComponent } from './dialogs/workflow_pause_dialog.component'

@Component({
  selector: 'workflow-component',
  templateUrl: 'workflow.component.html',
  styleUrls: ['./workflow.component.less'],
})
export class WorkflowComponent {
  @Input() workflow: Workflow
  @Input() duration: WorkflowDuration
  @Input() detailed = false
  can_stop = true
  can_pause = false
  can_resume = false
  can_delete = false
  right_stop = false
  right_retry = false
  right_delete = false
  right_duplicate = false
  first_name: string
  last_name: string
  user_name: string

  constructor(
    private authService: AuthService,
    private router: Router,
    private userService: UserService,
    private workflowService: WorkflowService,
    public dialog: MatDialog,
  ) {}

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

  switchDetailed() {
    this.detailed = !this.detailed
    if (this.workflow !== undefined && this.detailed) {
      this.authService
        .hasAnyRights('workflow::' + this.workflow.identifier, 'retry')
        .subscribe((response) => {
          this.right_retry = response.authorized
        })
    }
  }

  gotoVideo(video_id): void {
    this.router.navigate(['/videos'], { queryParams: { video_id: video_id } })
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

  pause(_workflow_id): void {
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
            // if response.status === "ok" {
            // }
          })
      }
    })
  }

  duplicate(): void {
    if (this.right_duplicate) {
      const parameters = this.workflow.parameters.reduce(function (
        map,
        parameter,
      ) {
        const value = parseInt(parameter.value)
        console.log(value)
        if (isNaN(value)) {
          map[parameter.id] = parameter.value
        } else {
          map[parameter.id] = value
        }
        return map
      },
      {})
      const create_workflow_parameters = new StartWorkflowDefinition()
      create_workflow_parameters.workflow_identifier = this.workflow.identifier
      create_workflow_parameters.parameters = parameters
      create_workflow_parameters.reference = this.workflow.reference
      create_workflow_parameters.version_major = parseInt(
        this.workflow.version_major,
      )
      create_workflow_parameters.version_minor = parseInt(
        this.workflow.version_minor,
      )
      create_workflow_parameters.version_micro = parseInt(
        this.workflow.version_micro,
      )

      this.workflowService
        .createWorkflow(create_workflow_parameters)
        .subscribe((response) => {
          console.log(response)
        })
    }
  }
}
