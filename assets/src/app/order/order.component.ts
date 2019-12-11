
import {Component, ViewChild} from '@angular/core'
import {ActivatedRoute, Router} from '@angular/router'
import {MatStepper} from '@angular/material';

import {S3Configuration} from '../models/s3'

import {WorkflowService} from '../services/workflow.service'
import {S3Service} from '../services/s3.service'

let Evaporate = require('evaporate');
let crypto = require('crypto');

@Component({
  selector: 'order-component',
  templateUrl: 'order.component.html',
  styleUrls: ['./order.component.less'],
})

export class OrderComponent {
  @ViewChild('stepper') stepper: MatStepper;
  s3Configuration: S3Configuration;
  progressBars = [];
  completed: number = 0;
  uploadCompleted = false;
  parameters: any = {};

  services = [
    {
      "id": "acs",
      "label": "Re-synchronisation du sous-titre basé sur l'audio",
      "icon": "sync",
      "parameters": [
        {
          "id": "ttmlSourceFile",
          "label": "TTML Source file",
          "type": "file"
        },
        {
          "id": "audioSourceFile",
          "label": "Audio Source file (can be video with audio)",
          "type": "file"
        }
      ]
    },
    {
      "id": "speech_to_text",
      "label": "Transcription",
      "icon": "subtitles",
      "parameters": [
        {
          "id": "audioSourceFile",
          "label": "Audio Source file",
          "type": "file",
          "accept": ".wav"
        },
        {
          "id": "language",
          "label": "Langue audio",
          "type": "choice",
          "default": "fr",
          "items": [
            {
              "id": "fr",
              "label": "Français"
            },
            {
              "id": "en",
              "label": "Anglais"
            }
          ]
        },
        {
          "id": "contentType",
          "label": "Type du contenu",
          "type": "choice",
          "default": "news",
          "items": [
            {
              "id": "documentary",
              "label": "Documentaire"
            },
            {
              "id": "fiction",
              "label": "Fiction"
            },
            {
              "id": "news",
              "label": "News"
            },
            {
              "id": "reportage",
              "label": "Reportage"
            }
          ]
        }
      ]
    }
  ]

  selectedService = undefined;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private s3Service: S3Service,
    private workflowService: WorkflowService
  ) {}

  ngOnInit() {
    this.s3Service.getConfiguration()
      .subscribe(s3Configuration => {
        this.s3Configuration = s3Configuration
      })
  }

  selectService(service) {
    this.selectedService = service;
    this.stepper.next();
  }

  upload() {
    var current = this
    current.completed = 0;
    current.progressBars = [];
    current.uploadCompleted = false;

    var config = {
      signerUrl: '/api/s3_signer',
      aws_key: this.s3Configuration.access_key,
      bucket: this.s3Configuration.bucket,
      aws_url: this.s3Configuration.url,
      computeContentMd5: true,
      cryptoMd5Method: function (data) {
        var buffer = new Buffer(data)
        return crypto.createHash('md5').update(buffer).digest('base64');
      },
      cryptoHexEncodedHash256: function (data) { return crypto.createHash('sha256').update(data).digest('hex'); },
    };

    var uploader = Evaporate.create(config)
      .then(function (evaporate) {
        
        var overrides = {
          bucket: current.s3Configuration.bucket
        }

        Object.entries(current.parameters).forEach(
          ([key, value]) => {
            if(typeof value == 'object') {
              const file = (<HTMLInputElement>value).files[0]
              current.progressBars.push({name: file.name, progress: 0});

              var fileConfig = {
                name: file.name,
                file: file,
                progress: function (progressValue) {
                  for(let item of current.progressBars) {
                    if(item.name == file.name) {
                      item.progress = progressValue * 100;
                    }
                  }
                },
                complete: function (_xhr, awsKey) {
                  current.completed += 1
                  if(current.completed == current.progressBars.length) {
                    current.uploadCompleted = true
                  }
                },
              }

              evaporate.add(fileConfig, overrides)
                .then(function (awsObjectKey) {
                  console.log('File successfully uploaded to:', awsObjectKey);
                },
                function (reason) {
                  console.log('File did not upload sucessfully:', reason);
                })
            }
          }
        );

      })
  }

  startWorkflow() {
    console.log(this.parameters)
    const workflowParameters = {
      "audio_source_filename": this.parameters.audioSourceFile._fileNames,
      "content_type": this.parameters.contentType,
      "language": this.parameters.language
    }

    this.workflowService.createSpecificWorkflow(this.selectedService.id, workflowParameters)
      .subscribe(response => {
        console.log(response)
      })
  }

  follow() {
    console.log("follow")
    this.router.navigate(['/orders'])
    // this.router.navigate(['/orders'], { queryParams: {order_id: response.workflow_id} })
  }
}
