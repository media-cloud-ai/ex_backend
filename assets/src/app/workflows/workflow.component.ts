
import {Component, Input} from '@angular/core'
import {Router} from '@angular/router'
import {MatDialog} from '@angular/material/dialog'

import {AuthService} from '../authentication/auth.service'
import {User} from '../models/user'
import {UserService} from '../services/user.service'
import {WorkflowService} from '../services/workflow.service'
import {Workflow, Step} from '../models/workflow'
import {WorkflowDuration} from '../models/statistics/duration'
import {WorkflowActionsDialogComponent} from './dialogs/workflow_actions_dialog.component'
import {WorkflowPauseDialogComponent} from './dialogs/workflow_pause_dialog.component'

@Component({
  selector: 'workflow-component',
  templateUrl: 'workflow.component.html',
  styleUrls: ['./workflow.component.less'],
})

export class WorkflowComponent {
  @Input() workflow: Workflow
  @Input() duration: WorkflowDuration
  @Input() detailed = false
  can_stop: boolean = false
  can_pause: boolean = false
  can_resume: boolean = false
  can_delete: boolean = false
  right_stop: boolean = false
  right_retry: boolean = false
  right_delete: boolean = false
  first_name: String
  last_name: String
  user_name: String

  constructor(
    private authService: AuthService,
    private router: Router,
    private userService: UserService,
    private workflowService: WorkflowService,
    public dialog: MatDialog
  ) {}

  ngOnInit() {
    this.workflow = Object.assign(new Workflow(), this.workflow);
    this.userService.getUserByUuid(this.workflow.user_uuid).subscribe(
        response => {
          this.user_name = response.data.email
          if (response.data.first_name && response.data.last_name) {
            this.first_name = response.data.first_name
            this.last_name = response.data.last_name
            this.user_name = response.data.username
          }
        })
  }

  onMoreActionsToggle() {
    this.can_stop = this.workflow.can_stop();
    if (this.can_stop && this.workflow.steps.some((s) => s.name === 'clean_workspace' && s.status !== 'queued')) {
      this.can_stop = false
    }

    this.can_pause = this.workflow.can_pause();
    this.can_resume = this.workflow.can_resume();
    this.can_delete = this.workflow.can_delete();

    this.authService.hasAnyRights("workflow::" + this.workflow.identifier, "abort").subscribe(
        response => {
          this.right_stop = response.authorized
      })
    this.authService.hasAnyRights("workflow::" + this.workflow.identifier, "delete").subscribe(
        response => {
          this.right_delete = response.authorized
      })
  }

  switchDetailed() {
    this.detailed = !this.detailed
    if (this.workflow !== undefined && this.detailed) {
      this.authService.hasAnyRights("workflow::" + this.workflow.identifier, "retry").subscribe(
        response => {
          this.right_retry = response.authorized
      })
    }
  }

  gotoVideo(video_id): void {
    this.router.navigate(['/videos'], { queryParams: {video_id: video_id} })
  }

  getStepsCount(): number {
    let count = 0
    for (let step of this.workflow.steps) {
      if (step.jobs.skipped > 0 ||
         step.jobs.completed > 0 ||
         step.jobs.errors > 0) {
        count++
      }
    }
    return count
  }

  getTotalSteps(): number {
    return this.workflow.steps.length
  }

  pause(workflow_id): void {
    let dialogRef = this.dialog.open(WorkflowPauseDialogComponent, {data: {
      'workflow': this.workflow
    }})

    dialogRef.afterClosed().subscribe(user_choice => {
      if (user_choice !== undefined && this.workflow.can_pause()) {
        this.workflowService.sendWorkflowEvent(user_choice.workflow.id, user_choice.event)
          .subscribe(response => {
            console.log(response)
          })
      }
    })
  }

  resume(workflow_id): void {
    let dialogRef = this.dialog.open(WorkflowActionsDialogComponent, {data: {
      'workflow': this.workflow,
      'message': 'resume'
    }})

    dialogRef.afterClosed().subscribe(workflow => {
      if (workflow !== undefined && this.workflow.can_resume()) {
        console.log('Resume workflow!')
        this.workflowService.sendWorkflowEvent(workflow.id, {event: 'resume'})
        .subscribe(response => {
          console.log(response)
        })
      }
    })
  }

  stop(workflow_id): void {
    let message = this.workflow.is_live ? 'stop' : 'abort';

    let dialogRef = this.dialog.open(WorkflowActionsDialogComponent, {data: {
      'workflow': this.workflow,
      'message': message
    }})

    dialogRef.afterClosed().subscribe(workflow => {
      if (workflow !== undefined && this.workflow.can_stop()) {
        console.log('Stop/abort workflow:', message)
        this.workflowService.sendWorkflowEvent(workflow.id, {event: message})
        .subscribe(response => {
          console.log(response)
        })
      }
    })
  }

  delete(workflow_id): void {
    let dialogRef = this.dialog.open(WorkflowActionsDialogComponent, {data: {
      'workflow': this.workflow,
      'message': 'delete'
    }})

    dialogRef.afterClosed().subscribe(workflow => {
      if (workflow !== undefined && this.workflow.can_delete()) {
        this.workflowService.sendWorkflowEvent(workflow.id, {event: 'delete'})
        .subscribe(response => {
          // if response.status === "ok" {
          // }
        })
      }
    })
  }
}
