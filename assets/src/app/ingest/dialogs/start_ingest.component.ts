import {Component, Inject} from '@angular/core'
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material'

import {Step} from '../../models/workflow'

@Component({
  selector: 'start-ingest-dialog',
  templateUrl: 'start_ingest.component.html',
  styleUrls: ['./start_ingest.component.less'],
})

export class StartIngestDialog {
  steps: Step[]

  constructor(
    public dialogRef: MatDialogRef<StartIngestDialog>,
    @Inject(MAT_DIALOG_DATA) public filename: string) {

    this.steps = [
      {
        id: 0,
        name: 'audio_extraction',
        enable: true,
        parent_ids:[],
        required: [],
        inputs: [
          {
            path: filename
          }
        ],
        output_extension: '.wav',
        parameters : [
          {
            id: 'output_codec_audio',
            type: 'string',
            enable: false,
            default: 'pcm_s24le',
            value: 'pcm_s24le'
          },
          {
            id: 'disable_video',
            type: 'boolean',
            enable: false,
            default: true,
            value: true
          },
          {
            id: 'disable_data',
            type: 'boolean',
            enable: false,
            default: true,
            value: true
          }
        ]
      },
      {
        id: 1,
        name: 'speech_to_text',
        enable: true,
        parent_ids:[0],
        required: ['speech_to_text'],
        parameters : [
          {
            id: 'mode',
            type: 'string',
            enable: false,
            default: 'conversation',
            value: 'conversation'
          },
          {
            id: 'language',
            type: 'string',
            enable: false,
            default: 'en-US',
            value: 'en-US'
          },
          {
            id: 'format',
            type: 'string',
            enable: false,
            default: 'simple',
            value: 'simple'
          }
        ]
      }
    ]
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
