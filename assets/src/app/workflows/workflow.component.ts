
import {Component, Input} from '@angular/core'
import {Router} from '@angular/router'
import {MatDialog} from '@angular/material/dialog'

import {AuthService} from '../authentication/auth.service'
import {UserService} from '../services/user.service'
import {WorkflowService} from '../services/workflow.service'
import {Workflow, Step} from '../models/workflow'
import {WorkflowAbortDialogComponent} from './dialogs/workflow_abort_dialog.component'
import {WorkflowPauseDialogComponent} from './dialogs/workflow_pause_dialog.component'

@Component({
  selector: 'workflow-component',
  templateUrl: 'workflow.component.html',
  styleUrls: ['./workflow.component.less'],
})

export class WorkflowComponent {
  @Input() workflow: Workflow
  @Input() detailed = false
  can_abort: boolean
  can_stop: boolean = true
  can_pause: boolean = false
  can_resume: boolean = false
  right_abort: boolean = false
  right_delete: boolean = false

  constructor(
    private authService: AuthService,
    private router: Router,
    private workflowService: WorkflowService,
    public dialog: MatDialog
  ) {}

  ngOnInit() {
    let has_at_least_one_queued_job = this.workflow.steps.some((s) => s['jobs']['queued'] == 1)
    let has_at_least_one_processing_step = this.workflow.steps.some((s) => s['status'] === "processing");
    let has_at_least_one_paused_step = this.workflow.steps.some((s) => s['status'] === "paused");

    this.can_abort = !has_at_least_one_queued_job && has_at_least_one_processing_step
    if (this.can_abort && this.workflow.steps.some((s) => s.name === 'clean_workspace' && s.status !== 'queued')) {
      this.can_abort = false
    }

    let last_step = this.workflow.steps[this.workflow.steps.length - 1];
    let is_last_step_processing = last_step['status'] === "processing";

    this.can_pause = this.can_abort && !has_at_least_one_paused_step && !is_last_step_processing;
    this.can_resume = has_at_least_one_paused_step;

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
    let dialogRef = this.dialog.open(WorkflowAbortDialogComponent, {data: {
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
    let dialogRef = this.dialog.open(WorkflowAbortDialogComponent, {data: {
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
    let dialogRef = this.dialog.open(WorkflowAbortDialogComponent, {data: {
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
    let dialogRef = this.dialog.open(WorkflowAbortDialogComponent, {data: {
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
