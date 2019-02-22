import {Component, Inject} from '@angular/core'
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material'

import {Step} from '../../models/workflow'
import {WorkflowRenderer} from '../../models/workflow_renderer'

import {WorkflowService} from '../../services/workflow.service'

@Component({
  selector: 'workflow_dialog',
  templateUrl: 'workflow_dialog.component.html',
  styleUrls: ['./workflow_dialog.component.less'],
})
export class WorkflowDialogComponent {
  acs_enable: boolean

  selected_tab = 0
  rdf_steps: Step[]
  dash_steps: Step[]
  acs_steps: Step[]
  rosetta_steps: Step[]

  constructor(
    public dialogRef: MatDialogRef<WorkflowDialogComponent>,
    private workflowService: WorkflowService,
    @Inject(MAT_DIALOG_DATA) public data: any) {
    console.log('data:', data)
    this.acs_enable = false
    if (data && !Array.isArray(data)) {
      this.acs_enable = data['broadcasted_live']
    }

    this.workflowService.getWorkflowDefinition("francetv_subtil_rdf_ingest", data['reference'])
      .subscribe(workflowDefinition => {
        this.rdf_steps = workflowDefinition.steps
      })

    this.workflowService.getWorkflowDefinition("francetv_subtil_dash_ingest", data['reference'])
      .subscribe(workflowDefinition => {
        this.dash_steps = workflowDefinition.steps
      })

    this.workflowService.getWorkflowDefinition("francetv_subtil_acs", data['reference'])
      .subscribe(workflowDefinition => {
        this.acs_steps = workflowDefinition.steps
      })

    this.workflowService.getWorkflowDefinition("ftv_studio_rosetta", data['reference'])
      .subscribe(workflowDefinition => {
        console.log(workflowDefinition)
        this.rosetta_steps = workflowDefinition.steps
      })
  }

  onNoClick(): void {
    this.dialogRef.close()
  }

  onClose(): void {
    var src_steps = []
    switch(this.selected_tab) {
      case 0: {
        src_steps = this.rdf_steps
        break;
      }
      case 1: {
        src_steps = this.dash_steps
        break;
      }
      case 2: {
        src_steps = this.acs_steps
        break;
      }
      case 3: {
        src_steps = this.rosetta_steps
        break;
      }
      default: {
        src_steps = this.rdf_steps
      }
    }

    var steps = []
    for (let step of src_steps) {
      if (step.enable === true) {
        steps.push(step)
      }
    }
    this.dialogRef.close(steps)
  }

  toNumber(param): void  {
    if (param.type === 'number') {
      param.value = +param.value
    }
  }
}
