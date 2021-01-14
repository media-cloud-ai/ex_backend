
import {Component, Input} from '@angular/core'
import {Router} from '@angular/router'
import {MatDialog} from '@angular/material/dialog'

import {AuthService} from '../authentication/auth.service'
import {WorkflowService} from '../services/workflow.service'
import {Workflow, Step} from '../models/workflow'
import {WorkflowAbortDialogComponent} from './dialogs/workflow_abort_dialog.component'

@Component({
  selector: 'workflow-component',
  templateUrl: 'workflow.component.html',
  styleUrls: ['./workflow.component.less'],
})

export class WorkflowComponent {
  @Input() workflow: Workflow
  @Input() detailed = false
  can_abort: boolean
  right_abort: boolean = false
  right_delete: boolean = false

  constructor(
    private authService: AuthService,
    private router: Router,
    private workflowService: WorkflowService,
    public dialog: MatDialog
  ) {}

  ngOnInit() {
    this.can_abort = this.workflow.steps.some((s) => s['status'] === 'error')
    if (this.can_abort && this.workflow.steps.some((s) => s.name === 'clean_workspace' && s['status'] !== 'queued')) {
      this.can_abort = false
    }

    let authorized_to_abort = this.workflow.rights.find((r) => r.action === "abort")
    if (authorized_to_abort !== undefined) {
      this.right_abort = this.authService.hasAnyRights(authorized_to_abort.groups)
    }

    let authorized_to_delete = this.workflow.rights.find((r) => r.action === "delete")
    if (authorized_to_delete !== undefined) {
      this.right_delete = this.authService.hasAnyRights(authorized_to_delete.groups)
    }
  }

  switchDetailed() {
    this.detailed = !this.detailed
  }

  gotoVideo(video_id): void {
    this.router.navigate(['/videos'], { queryParams: {video_id: video_id} })
  }

  goToDetails(workflow_id): void {
    this.router.navigate(['/workflows', workflow_id])
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
