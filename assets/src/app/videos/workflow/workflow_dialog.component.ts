import {Component, Inject} from '@angular/core';
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material';
import {Step} from '../../models/workflow';

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
        "id": "download_http",
        "parameters": []
      },{
        "id": "ttml_to_mp4",
        "parameters": []
      },{
        "id": "set_language",
        "parameters" : data.languages
      },{
        "id": "generate_dash",
        "parameters" : [
          {
            "id": "segment_duration",
            "type": "number",
            "default": 2000,
            "value": 2000,
          },{
            "id": "fragment_duration",
            "type": "number",
            "default": 2000,
            "value": 2000,
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
