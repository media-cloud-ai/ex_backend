import {Component, Inject} from '@angular/core'
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material'
import {Workflow} from '../../models/workflow'

@Component({
  selector: 'workflow_abort_dialog',
  templateUrl: 'workflow_abort_dialog.component.html',
  styleUrls: ['./workflow_abort_dialog.component.less'],
})
export class WorkflowAbortDialogComponent {

  workflow: Workflow
  type: string

  constructor(
    public dialogRef: MatDialogRef<WorkflowAbortDialogComponent>,
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
