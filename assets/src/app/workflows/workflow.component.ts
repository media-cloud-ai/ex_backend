
import {Component, Input} from '@angular/core'
import {Router} from '@angular/router'
import {MatDialog} from '@angular/material'

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
  can_abort: boolean

  constructor(
    private router: Router,
    private workflowService: WorkflowService,
    public dialog: MatDialog
  ) {}

  ngOnInit() {
    this.can_abort = this.workflow.flow.steps.some((s) => s['status'] === 'error')
    if (this.can_abort && this.workflow.flow.steps.some((s) => s.name === 'clean_workspace' && s['status'] !== 'queued')) {
      this.can_abort = false
    }
  }

  gotoVideo(video_id): void {
    this.router.navigate(['/videos'], { queryParams: {video_id: video_id} })
  }

  goToDetails(workflow_id): void {
    this.router.navigate(['/workflows', workflow_id])
  }

  getStepsCount(): number {
    let count = 0
    for (let step of this.workflow.flow.steps) {
      if (step.jobs.skipped > 0 ||
         step.jobs.completed > 0 ||
         step.jobs.errors > 0) {
        count++
      }
    }
    return count
  }
  
  getTotalSteps(): number {
    return this.workflow['flow'].steps.length
  }

  abort(workflow_id): void {
    let dialogRef = this.dialog.open(WorkflowAbortDialogComponent, {data: {'workflow': this.workflow}})

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
}
