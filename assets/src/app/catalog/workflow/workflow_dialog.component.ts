import {Component, Inject} from '@angular/core'
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material'

import {Step, Workflow} from '../../models/workflow'
import {WorkflowRenderer} from '../../models/workflow_renderer'

import {AuthService} from '../../authentication/auth.service'
import {WorkflowService} from '../../services/workflow.service'

@Component({
  selector: 'workflow_dialog',
  templateUrl: 'workflow_dialog.component.html',
  styleUrls: ['./workflow_dialog.component.less'],
})
export class WorkflowDialogComponent {
  acs_enable: boolean
  ftvstudio : boolean

  selected_tab = 0
  rdf_workflow: Workflow
  dash_workflow: Workflow
  acs_workflow: Workflow
  rosetta_workflow: Workflow

  constructor(
    public authService: AuthService,
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
        this.rdf_workflow = workflowDefinition
      })

    this.workflowService.getWorkflowDefinition("francetv_subtil_dash_ingest", data['reference'])
      .subscribe(workflowDefinition => {
        this.dash_workflow = workflowDefinition
      })

    this.workflowService.getWorkflowDefinition("francetv_subtil_acs", data['reference'])
      .subscribe(workflowDefinition => {
        this.acs_workflow = workflowDefinition
      })

    this.workflowService.getWorkflowDefinition("ftv_studio_rosetta", data['reference'])
      .subscribe(workflowDefinition => {
        console.log(workflowDefinition)
        this.rosetta_workflow = workflowDefinition
      })
  }
  
  ngOnInit() {
    this.ftvstudio = this.authService.hasFtvStudioRight()
  }
  
  onNoClick(): void {
    this.dialogRef.close()
  }

  onClose(): void {
    var workflow = undefined
    switch(this.selected_tab) {
      case 0: {
        workflow = this.rdf_workflow
        break;
      }
      case 1: {
        workflow = this.dash_workflow
        break;
      }
      case 2: {
        workflow = this.acs_workflow
        break;
      }
      case 3: {
        workflow = this.rosetta_workflow
        break;
      }
      default: {
        workflow = this.rdf_workflow
      }
    }

    this.dialogRef.close(workflow)
  }

  toNumber(param): void  {
    if (param.type === 'number') {
      param.value = +param.value
    }
  }
}
