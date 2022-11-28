import { Component, Inject } from '@angular/core'
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog'
import { Workflow } from '../../models/workflow'

@Component({
  selector: 'workflow_pause_dialog',
  templateUrl: 'workflow_pause_dialog.component.html',
  styleUrls: ['./workflow_pause_dialog.component.less'],
})
export class WorkflowPauseDialogComponent {
  workflow: Workflow
  action: string
  date: Date
  delay = 0
  now = new Date()

  available_actions = ['abort', 'resume']

  constructor(
    public dialogRef: MatDialogRef<WorkflowPauseDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any,
  ) {
    this.workflow = data.workflow
  }

  forceWorkspaceClean(): boolean {
    return !this.workflow.steps.some((s) => s.name === 'clean_workspace')
  }

  onNoClick(): void {
    this.dialogRef.close()
  }

  onClose(): void {
    const response = {
      workflow: this.workflow,
      event: {
        event: 'pause',
        post_action: this.action,
        trigger_at: this.date.getTime(),
      },
    }
    this.dialogRef.close(response)
  }

  onActionSelection(event) {
    this.action = event.value
  }
}
