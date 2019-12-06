
import {Component} from '@angular/core'
import {ActivatedRoute, Router} from '@angular/router'

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
  is_new_order: boolean = false
  order_id: number
  wav_file: any
  selected_langages: string = "fr"
  customer_vocab: string = " "
  wav_percent_uploaded = 0
  completed = 0
  s3_configuration: S3Configuration

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private s3Service: S3Service,
    private workflowService: WorkflowService
  ) {}

  ngOnInit() {
    this.route
      .params.subscribe(params => {
        if(params['id'] == 'new') {
          this.is_new_order = true
        } else {
          this.order_id = params['id']
        }
      })

    this.s3Service.getConfiguration()
      .subscribe(s3_configuration => {
        this.s3_configuration = s3_configuration
      })
  }

  upload() {
    var wav_file = this.wav_file.files[0]
    var current = this
    this.wav_percent_uploaded = 0;
    current.completed = 0;

    var config = {
      signerUrl: '/api/s3_signer',
      aws_key: this.s3_configuration.access_key,
      bucket: 'stt',
      aws_url: this.s3_configuration.url,
      computeContentMd5: true,
      cryptoMd5Method: function (data) {
        console.log(data, crypto.createHash('md5'))
        var buffer = new Buffer(data)
        return crypto.createHash('md5').update(buffer).digest('base64');
      },
      cryptoHexEncodedHash256: function (data) { return crypto.createHash('sha256').update(data).digest('hex'); },
    };

    var uploader = Evaporate.create(config)
      .then(function (evaporate) {
        var wavConfig = {
          name: wav_file.name,
          file: wav_file,
          progress: function (progressValue) {
            current.wav_percent_uploaded = progressValue * 100;
          },
          complete: function (_xhr, awsKey) {
            current.completed += 1
            if(current.completed == 2) {
              current.launch_workflow(wav_file.name)
            }
          },
        }
        var overrides = {
          bucket: 'stt'
        }

        evaporate.add(wavConfig, overrides)
          .then(function (awsObjectKey) {
            console.log('File successfully uploaded to:', awsObjectKey);
          },
          function (reason) {
            console.log('File did not upload sucessfully:', reason);
          })
      })
  }

  launch_workflow(wav_filename) {
    var params = new Array(
      "credential_aws_secret_key=MEDIAIO_BUCKET_STT",
      "hostname=" + this.s3_configuration.url,
      "region=" + this.s3_configuration.region,
    ); 

    var source_wav_url = "s3://" + this.s3_configuration.bucket + "/" + wav_filename + "?" + params.join("&")
    var output_url = "s3://" + this.s3_configuration.bucket + "/output.txt?" + params.join("&")

    this.workflowService.getStandaloneWorkflowDefinition("ftv_acs_standalone", source_wav_url, output_url)
      .subscribe(workflowDefinition => {
        workflowDefinition['reference'] = output_url

        this.workflowService.createWorkflow(workflowDefinition)
        .subscribe(response => {
          console.log(response)
        })
    })
  }

  start_via_uuid() {
    var parameters = {
      "reference": this.customer_vocab
    }

    this.workflowService.createSpecificWorkflow("ftv-acs-standalone", this.customer_vocab)
    .subscribe(response => {
      this.router.navigate(['/orders'], { queryParams: {order_id: response.workflow_id} })
    })
  }
}
