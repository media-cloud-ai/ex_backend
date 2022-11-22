import { Component, ViewChild } from '@angular/core'
import { ActivatedRoute, Router } from '@angular/router'
import { MatStepper } from '@angular/material/stepper'

import { S3Configuration } from '../models/s3'
import { StartWorkflowDefinition } from '../models/startWorkflowDefinition'

import { WorkflowService } from '../services/workflow.service'
import { S3Service } from '../services/s3.service'

import { Evaporate } from 'evaporate'
import * as crypto from 'crypto'

export class ProcessStatus {
  failed = true
  message = ''
}

@Component({
  selector: 'order-component',
  templateUrl: 'order.component.html',
  styleUrls: ['./order.component.less'],
})
export class OrderComponent {
  @ViewChild('stepper') stepper: MatStepper
  serviceLength = 0
  versionLength = 0
  pageSize = 10
  page = 0
  pageSizeOptions = [10, 20, 50, 100]
  search = ''
  s3Configuration: S3Configuration
  progressBars = []
  completed = 0
  uploadCompleted = false
  parameters: any = {}
  processStatus: ProcessStatus = {
    failed: true,
    message: '',
  }

  services = []

  selectedService = undefined
  selectedServiceVersion = []

  response = undefined

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private s3Service: S3Service,
    private workflowService: WorkflowService,
  ) {}

  ngOnInit() {
    this.s3Service.getConfiguration().subscribe((s3Configuration) => {
      this.s3Configuration = s3Configuration
    })

    this.workflowService
      .getWorkflowDefinitions(
        this.page,
        this.pageSize,
        'create',
        undefined,
        ['latest'],
        'full',
      )
      .subscribe((definitions) => {
        this.services = definitions.data
        this.serviceLength = definitions.total
      })
  }

  loadWorkflows() {
    this.workflowService
      .getWorkflowDefinitions(
        this.page,
        this.pageSize,
        'create',
        this.search,
        ['latest'],
        'full',
      )
      .subscribe((definitions) => {
        this.services = definitions.data
        this.serviceLength = definitions.total
      })
  }

  selectService(service) {
    this.selectedService = service

    this.workflowService
      .getWorkflowDefinitions(
        this.page,
        this.pageSize,
        'create',
        this.selectedService.identifier,
        [],
        'full',
      )
      .subscribe((definitions) => {
        this.selectedServiceVersion = definitions.data
        this.versionLength = definitions.total
      })

    this.stepper.next()
  }

  selectVersion(service) {
    this.selectedService = service
    this.stepper.next()
  }

  upload() {
    const current = this
    current.completed = 0
    current.progressBars = []
    current.uploadCompleted = false

    const config = {
      signerUrl: '/api/s3_signer',
      aws_key: this.s3Configuration.access_key,
      bucket: this.s3Configuration.bucket,
      aws_url: this.s3Configuration.url,
      awsRegion: this.s3Configuration.region,
      computeContentMd5: true,
      cryptoMd5Method: function (data) {
        const buffer = new Buffer(data)
        return crypto.createHash('md5').update(buffer).digest('base64')
      },
      cryptoHexEncodedHash256: function (data) {
        return crypto.createHash('sha256').update(data).digest('hex')
      },
    }

    const _uploader = Evaporate.create(config).then(function (evaporate) {
      const overrides = {
        bucket: current.s3Configuration.bucket,
      }

      Object.entries(current.parameters).forEach(([_key, value]) => {
        if (typeof value == 'object') {
          const file = <HTMLInputElement>value
          current.progressBars.push({ name: file.name, progress: 0 })
          const fileConfig = {
            name: file.name,
            file: file,
            progress: function (progressValue) {
              for (const item of current.progressBars) {
                if (item.name == file.name) {
                  item.progress = progressValue * 100
                }
              }
            },
            complete: function (_xhr, _awsKey) {
              current.completed += 1
              if (current.completed == current.progressBars.length) {
                current.uploadCompleted = true
              }
            },
          }

          evaporate.add(fileConfig, overrides).then(
            function (awsObjectKey) {
              console.log('File successfully uploaded to:', awsObjectKey)
            },
            function (reason) {
              console.log('File did not upload sucessfully:', reason)
            },
          )
        }
      })

      if (current.progressBars.length === 0) {
        current.uploadCompleted = true
      }
    })
  }

  parameterChange(parameter_id, event) {
    this.parameters[parameter_id] = event.target.value
  }

  getDefaultParameterValue(parameter) {
    if (this.parameters[parameter.id] == undefined) {
      this.parameters[parameter.id] = parameter.default
    }
    if (parameter.type == 'string') {
      return this.parameters[parameter.id] || ''
    }
    return this.parameters[parameter.id]
  }

  startWorkflow() {
    const parameters = {}

    for (let i = 0; i < this.selectedService.start_parameters.length; i++) {
      const parameter = this.selectedService.start_parameters[i]

      let value = this.parameters[parameter.id]
      if (value && value.name) {
        value = value.name
        if (this.selectedService.reference === undefined) {
          this.selectedService.reference = value
        }
      }

      if (typeof value === 'number') {
        value = value.toString()
      }

      parameters[parameter.id] = value
    }

    if (this.selectedService.reference === undefined) {
      this.selectedService.reference = this.selectedService.identifier
    }

    const startWorkflowDefinition: StartWorkflowDefinition = {
      workflow_identifier: this.selectedService.identifier,
      parameters: parameters,
      reference: this.selectedService.reference,
      version_major: this.selectedService.version_major,
      version_minor: this.selectedService.version_minor,
      version_micro: this.selectedService.version_micro,
    }

    this.workflowService
      .createWorkflow(startWorkflowDefinition)
      .subscribe((response) => {
        if (response) {
          this.processStatus.failed = false
          this.processStatus.message = 'Your order is being processed.'
          this.response = response
        } else {
          this.processStatus.failed = true
          this.processStatus.message = 'An error occured.'
        }
      })
  }

  follow() {
    console.log('follow')
    this.router.navigate(['/workflows/' + this.response.data.id])
  }

  eventGetWorkflows(event) {
    this.workflowService
      .getWorkflowDefinitions(
        event.pageIndex,
        event.pageSize,
        'create',
        this.search,
        ['latest'],
        'full',
      )
      .subscribe((definitions) => {
        this.services = definitions.data
        this.serviceLength = definitions.total
      })
  }
}
