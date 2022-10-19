
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
  can_abort: boolean
  can_stop: boolean = true
  can_pause: boolean = false
  can_resume: boolean = false
  right_abort: boolean = false
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
    let is_paused = ["pausing", "paused"].includes(this.workflow.status.state);
    let has_at_least_one_queued_job = this.workflow.steps.some((s) => s['jobs']['queued'] == 1)
    let has_at_least_one_processing_step = this.workflow.steps.some((s) => s['status'] === "processing");

    let has_at_least_one_paused_step = this.workflow.steps.some((s) => s['status'] === "paused");
    let has_at_least_one_skipped_step = this.workflow.steps.some((s) => s['status'] === "skipped");

    this.can_abort = !has_at_least_one_queued_job && has_at_least_one_processing_step
    if (this.can_abort && this.workflow.steps.some((s) => s.name === 'clean_workspace' && s.status !== 'queued')) {
      this.can_abort = false
    }

    let last_step = this.workflow.steps[this.workflow.steps.length - 1];
    let is_last_step_processing = last_step['jobs']['processing'] == 1;
    let is_finished = this.workflow.artifacts.length > 0;

    this.can_pause = !is_finished && (has_at_least_one_queued_job || has_at_least_one_processing_step) && !is_paused && !is_last_step_processing;
    this.can_resume = has_at_least_one_paused_step;
    this.can_delete = !this.workflow.deleted

    this.authService.hasAnyRights("workflow::" + this.workflow.identifier, "abort").subscribe(
        response => {
          this.right_abort = response.authorized
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
      if (user_choice !== undefined) {
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
      if (workflow !== undefined) {
        console.log('Resume workflow!')
        this.workflowService.sendWorkflowEvent(workflow.id, {event: 'resume'})
        .subscribe(response => {
          console.log(response)
        })
      }
    })
  }

  abort(workflow_id): void {
    let dialogRef = this.dialog.open(WorkflowActionsDialogComponent, {data: {
      'workflow': this.workflow,
      'message': 'abort'
    }})

    dialogRef.afterClosed().subscribe(workflow => {
      if (workflow !== undefined) {
        console.log('Abort workflow!')
        this.workflowService.sendWorkflowEvent(workflow.id, {event: 'abort'})
        .subscribe(response => {
          console.log(response)
        })
      }
    })
  }

  stop(workflow_id): void {
    let dialogRef = this.dialog.open(WorkflowActionsDialogComponent, {data: {
      'workflow': this.workflow,
      'message': 'stop'
    }})

    dialogRef.afterClosed().subscribe(workflow => {
      if (workflow !== undefined) {
        console.log('Stop workflow!')
        this.workflowService.sendWorkflowEvent(workflow.id, {event: 'stop'})
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
      if (workflow !== undefined) {
        this.workflowService.sendWorkflowEvent(workflow.id, {event: 'delete'})
        .subscribe(response => {
          // if response.status === "ok" {
          // }
        })
      }
    })
  }
}
