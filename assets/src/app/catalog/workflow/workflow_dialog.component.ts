import {Component, Inject} from '@angular/core';
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material';
import {Step} from '../../models/workflow';
import {WorkflowRenderer} from '../../models/workflow_renderer';

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
    this.acs_enable = false;
    if(data && !Array.isArray(data)) {
      this.acs_enable = data["broadcasted_live"];
    }
    
    this.steps = [
      {
        id: 0,
        name: "download_ftp",
        enable: true,
        parent_ids:[],
        required: []
      },{
        id: 1,
        parent_ids: [0],
        name: "download_http",
        enable: true,
        required: [
          "download_ftp"
        ]
      },{
        id: 2,
        parent_ids: [0],
        name: "audio_extraction",
        enable: true,
        required: [
          "download_ftp"
        ]
      },{
        id: 3,
        parent_ids: [2],
        name: "audio_decode",
        enable: this.acs_enable,
        required: [
          "audio_extraction"
        ]
      },{
        id: 4,
        parent_ids: [3],
        name: "acs_prepare_audio",
        enable: this.acs_enable,
        required: [
          "audio_decode"
        ]
      },{
        id: 5,
        parent_ids: [4],
        name: "acs_synchronize",
        enable: this.acs_enable,
        required: [
          "acs_prepare_audio"
        ],
        parameters : [
          {
            id: "threads_number",
            type: "number",
            default: 8,
            value: 8
          },
          {
            id: "keep_original",
            type: "boolean",
            default: false,
            value: false
          }
        ]
      },{
        id: 6,
        parent_ids: [1, 5],
        name: "ttml_to_mp4",
        enable: true,
        required: [
          "download_http"
        ]
      },{
        id: 7,
        parent_ids: [6],
        name: "set_language",
        enable: true,
        required: [
          "audio_extraction",
          "ttml_to_mp4"
        ]
      },{
        id: 8,
        parent_ids: [7],
        name: "generate_dash",
        enable: true,
        required: [
          "set_language"
        ],
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
        id: 9,
        parent_ids: [8],
        name: "upload_ftp",
        enable: true,
        required: [
          "generate_dash"
        ]
      },{
        id: 10,
        parent_ids: [9],
        name: "push_rdf",
        enable: true,
        required: [
          "upload_ftp"
        ]
      },{
        id: 11,
        parent_ids: [10],
        name: "clean_workspace",
        enable: true,
        required: [
          "download_ftp"
        ]
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

  toNumber(param): void  {
    if(param.type == "number") {
      param.value = +param.value;
    }
  }
}
