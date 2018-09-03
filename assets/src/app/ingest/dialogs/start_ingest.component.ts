import {Component, Inject} from '@angular/core'
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material'

import {WorkflowService} from '../../services/workflow.service'
import {Step} from '../../models/workflow'

export class Data {
  path: string
  agent: string
}

@Component({
  selector: 'start-ingest-dialog',
  templateUrl: 'start_ingest.component.html',
  styleUrls: ['./start_ingest.component.less'],
})

export class StartIngestDialog {
  steps: Step[]
  workflow_data: Data

  constructor(
    public dialogRef: MatDialogRef<StartIngestDialog>,
    private workflowService: WorkflowService,
    @Inject(MAT_DIALOG_DATA) public data: Data) {
    this.workflow_data = data
  }

  ngOnInit() {
    this.workflowService.getWorkflowDefinition("ebu_ingest").subscribe(workflowDefinition => {
      this.steps = workflowDefinition.steps

      for(var step of this.steps) {
        if(step.inputs) {
          for(var input of step.inputs) {
            if(input.path) {
              input.path = this.workflow_data.path
            }
            if(input.agent) {
              input.agent = this.workflow_data.agent
            }
          }
        }
      }
    });
  }

  onNoClick() {
    this.dialogRef.close()
  }

  onClose() {
    var steps = []
    for (let step of this.steps) {
      if (step.enable === true) {
        steps.push(step)
      }
    }
    this.dialogRef.close(steps)
  }
}
