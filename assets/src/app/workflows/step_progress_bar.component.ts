
import {Component, EventEmitter, Input, Output} from '@angular/core'
import {MatSnackBar} from '@angular/material/snack-bar'
import {Step, Workflow} from '../models/workflow'

import {AuthService} from '../authentication/auth.service'
import {JobService} from '../services/job.service'
import {WorkflowService} from '../services/workflow.service'

@Component({
  selector: 'step-progress-bar-component',
  templateUrl: 'step_progress_bar.component.html',
  styleUrls: ['./step_progress_bar.component.less'],
})

export class StepProgressBarComponent {
  @Input() step: Step
  @Input() workflow: Workflow
  @Input() detailed: boolean
  right_retry: boolean = false

  constructor(
    private authService: AuthService,
    private snackBar: MatSnackBar,
    private jobService: JobService,
    private workflowService: WorkflowService,
  ){}

  ngOnInit() {
    if (this.workflow !== undefined) {
      let authorized_to_retry = this.workflow.rights.find((r) => r.action === "retry")
      if (authorized_to_retry !== undefined) {
        this.right_retry = this.authService.hasAnyRights(authorized_to_retry.groups)
      }
    }
  }

  retry(step) {
    const workflowService = this.workflowService;
    const workflow_id = this.workflow.id;

    this.jobService.getJobs(0, 100, this.workflow.id, step.id, step.name)
    .subscribe(jobPage => {
      var count = 0
      jobPage.data.forEach(function(job) {
        if(job.status[job.status.length - 1].state == "error") {
          count += 1
          workflowService.sendWorkflowEvent(workflow_id, {event: 'retry', job_id: job.id})
          .subscribe(response => {
          })
        }
      })

      let snackBarRef = this.snackBar.open("Restarted " + count + " \"" + step.name + "\" jobs", "", {
        duration: 1000,
      })
    })
  }

}
