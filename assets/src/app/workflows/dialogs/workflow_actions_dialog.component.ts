import {Component, Inject} from '@angular/core'
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material/dialog'
import {Workflow} from '../../models/workflow'

@Component({
  selector: 'workflow_actions_dialog',
  templateUrl: 'workflow_actions_dialog.component.html',
  styleUrls: ['./workflow_actions_dialog.component.less'],
})
export class WorkflowActionsDialogComponent {

  workflow: Workflow
  type: string

  constructor(
    public dialogRef: MatDialogRef<WorkflowActionsDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any) {

    console.log(data)
    this.workflow = data.workflow
    this.type = data.message
  }

  forceWorkspaceClean(): boolean {
    return !this.workflow.steps.some((s) => s.name === 'clean_workspace')
  }

  onNoClick(): void {
    this.dialogRef.close()
  }

  onClose(): void {
    this.dialogRef.close(this.workflow)
  }
}
