
import { Component, ViewChild } from '@angular/core'
import { ActivatedRoute, Router } from '@angular/router'
import { MatStepper } from '@angular/material/stepper';

import { S3Configuration } from '../models/s3'
import { StartWorkflowDefinition } from '../models/startWorkflowDefinition'

import { WorkflowService } from '../services/workflow.service'
import { S3Service } from '../services/s3.service'

let Evaporate = require('evaporate');
let crypto = require('crypto');

export class ProcessStatus {
  failed: boolean = true;
  message: string = "";
}

@Component({
  selector: 'order-component',
  templateUrl: 'order.component.html',
  styleUrls: ['./order.component.less'],
})
export class OrderComponent {
  @ViewChild('stepper') stepper: MatStepper;
  length = 1000
  pageSize = 10
  page = 0
  pageSizeOptions = [
    10,
    20,
    50,
    100
  ]
  s3Configuration: S3Configuration;
  progressBars = [];
  completed: number = 0;
  uploadCompleted = false;
  parameters: any = {};
  processStatus: ProcessStatus = {
    failed: true,
    message: ""
  };

  services = []

  selectedService = undefined;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private s3Service: S3Service,
    private workflowService: WorkflowService
  ) { }

  ngOnInit() {
    this.s3Service.getConfiguration()
      .subscribe(s3Configuration => {
        this.s3Configuration = s3Configuration
      })

    this.workflowService.getWorkflowDefinitions(this.page, this.pageSize, "create", undefined, ["latest"], "full")
      .subscribe(definitions => {
        this.services = definitions.data
        this.length = definitions.total
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
      awsRegion: this.s3Configuration.region,
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
            if (typeof value == 'object') {
              const file = (<HTMLInputElement>value)
              current.progressBars.push({ name: file.name, progress: 0 });
              var fileConfig = {
                name: file.name,
                file: file,
                progress: function (progressValue) {
                  for (let item of current.progressBars) {
                    if (item.name == file.name) {
                      item.progress = progressValue * 100;
                    }
                  }
                },
                complete: function (_xhr, awsKey) {
                  current.completed += 1
                  if (current.completed == current.progressBars.length) {
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

        if (current.progressBars.length === 0) {
          current.uploadCompleted = true;
        }
      })
  }

  parameterChange(parameter_id, event) {
    this.parameters[parameter_id] = event.target.value
  }

  getDefaultParameterValue(parameter) {
    if (this.parameters[parameter.id] == undefined) {
      this.parameters[parameter.id] = parameter.default;
    }
    if (parameter.type == "string") {
      return this.parameters[parameter.id] || "";
    }
    return this.parameters[parameter.id];
  }

  startWorkflow() {
    let parameters = {};

    for (let i = 0; i < this.selectedService.start_parameters.length; i++) {
      const parameter = this.selectedService.start_parameters[i];

      let value = this.parameters[parameter.id];
      if (value && value.name) {
        value = value.name;
        if (this.selectedService.reference === undefined) {
          this.selectedService.reference = value;
        }
      }

      if (typeof value === "number") {
        value = value.toString()
      }

      parameters[parameter.id] = value;
    }

    if (this.selectedService.reference === undefined) {
      this.selectedService.reference = this.selectedService.identifier;
    }

    let startWorkflowDefinition: StartWorkflowDefinition = {
      "workflow_identifier": this.selectedService.identifier,
      "parameters": parameters,
      "reference": this.selectedService.reference
    };

    this.workflowService.createWorkflow(startWorkflowDefinition)
      .subscribe(response => {
        if (response) {
          this.processStatus.failed = false;
          this.processStatus.message = "Votre commande est en cours de réalisation.";
        } else {
          this.processStatus.failed = true;
          this.processStatus.message = "Une erreur est apparue.";
        }
      })
  }

  follow() {
    console.log("follow")
    this.router.navigate(['/orders'])
    // this.router.navigate(['/orders'], { queryParams: {order_id: response.workflow_id} })
  }

  eventGetWorkflows(event) {
    this.workflowService.getWorkflowDefinitions(event.pageIndex, event.pageSize, "create", undefined, ["latest"], "simple")
      .subscribe(definitions => {
        this.services = definitions.data
        this.length = definitions.total
      })
  }
}
