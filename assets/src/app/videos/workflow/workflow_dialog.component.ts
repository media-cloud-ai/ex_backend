import {Component, Inject} from '@angular/core';
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material';
import {Step} from '../../models/workflow';

@Component({
  selector: 'workflow_dialog',
  templateUrl: 'workflow_dialog.component.html',
  styleUrls: ['./workflow_dialog.component.less'],
})
export class WorkflowDialogComponent {

  acs_enable: boolean;
  steps: Step[];

  constructor(public dialogRef: MatDialogRef<WorkflowDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any) {
    console.log("data:", data);
    this.acs_enable = data["broadcasted_live"];
    this.steps = [
      {
        id: "download_ftp",
        enable: true,
        parameters: []
      },{
        id: "download_http",
        enable: true,
        parameters: []
      },{
        id: "audio_extraction",
        enable: true,
        parameters : []
      // },{
      //   id: "audio_decode",
      //   enable: this.acs_enable,
      //   parameters : []
      // },{
      //   id: "acs_prepare_audio",
      //   enable: this.acs_enable,
      //   parameters : []
      // },{
      //   id: "acs_synchronize",
      //   enable: this.acs_enable,
      //   parameters : []
      // },{
      //   id: "audio_encode",
      //   enable: this.acs_enable,
      //   parameters : []
      },{
        id: "ttml_to_mp4",
        enable: true,
        parameters: []
      },{
        id: "set_language",
        enable: true,
        parameters : []
      },{
        id: "generate_dash",
        enable: true,
        parameters : [
          {
            id: "segment_duration",
            type: "number",
            default: 2000,
            value: 2000,
          },{
            id: "fragment_duration",
            type: "number",
            default: 2000,
            value: 2000,
          }
        ]
      },{
        id: "upload_ftp",
        enable: true,
        parameters: []
      },{
        id: "clean_workspace",
        enable: true,
        parameters: []
      }
    ]
  }

  onNoClick(): void {
    this.dialogRef.close();
  }

  onClose(): void {
    var steps = [];
    for(let step of this.steps) {
      if(step.enable == true) {
        steps.push(step);
      }
    }
    this.dialogRef.close(steps);
  }
}
