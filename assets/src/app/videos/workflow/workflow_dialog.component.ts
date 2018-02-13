import {Component, Inject} from '@angular/core';
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material';
import {Step} from '../../services/workflow';

@Component({
  selector: 'workflow_dialog',
  templateUrl: 'workflow_dialog.component.html',
  styleUrls: ['./workflow_dialog.component.less'],
})
export class WorkflowDialogComponent {

  steps: Step[];

  constructor(
    public dialogRef: MatDialogRef<WorkflowDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any) {
    this.steps = [
      {
        "id": "download_ftp",
        "parameters": []
      },{
        "id": "generate_dash",
        "parameters" : [
          {
            "id": "segment_duration",
            "type": "number",
            "default": 30000,
            "value": 30000,
          },{
            "id": "fragment_duration",
            "type": "number",
            "default": 10000,
            "value": 10000,
          }
        ]
      },{
        "id": "upload_ftp",
        "parameters": []
      }
    ]
  }

  onNoClick(): void {
    this.dialogRef.close();
  }
}
