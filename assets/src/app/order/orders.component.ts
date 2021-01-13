
import { Component } from '@angular/core'
import { ActivatedRoute, Router } from '@angular/router'

import { AuthService } from '../authentication/auth.service'
import { SocketService } from '../services/socket.service'
import { S3Service } from '../services/s3.service'
import { WorkflowService } from '../services/workflow.service'

import { Message } from '../models/message'
import { WorkflowPage } from '../models/page/workflow_page'
import { WorkflowQueryParams } from '../models/page/workflow_page'
import { Workflow } from '../models/workflow'

@Component({
  selector: 'orders-component',
  templateUrl: 'orders.component.html',
  styleUrls: ['./orders.component.less'],
})

export class OrdersComponent {
  sub = undefined
  loading = true
  page = 0
  pageSize = 10
  length = 1000
  pageSizeOptions = [
    10,
    20,
    50,
    100
  ]
  reference: string
  order_id: number
  after_date: undefined
  before_date: undefined
  technician: boolean

  parameters: WorkflowQueryParams
  selectedMode = []
  workflows: WorkflowPage
  connections: any = []

  constructor(
    private authService: AuthService,
    private route: ActivatedRoute,
    private router: Router,
    private socketService: SocketService,
    private workflowService: WorkflowService,
    private s3Service: S3Service,
  ) {
    let today = new Date();
    let yesterday = new Date();
    yesterday.setDate(today.getDate() - 1);
    this.parameters = {
      identifiers: [
        "acs",
        "acs_and_asp",
        "speech_to_text",
        "dialog_enhancement"
      ],
      start_date: yesterday,
      end_date: today,
      status: [
        "completed"
      ],
      detailed: false,
      time_interval: 1
    };
  }

  ngOnInit() {
    this.technician = this.authService.hasTechnicianRight();
    this.sub = this.route
      .queryParams
      .subscribe(params => {
        this.page = +params['page'] || 0
        this.pageSize = +params['per_page'] || 10
        this.getWorkflows(this.page, this.pageSize, this.parameters)

        this.socketService.initSocket()
        this.socketService.connectToChannel('notifications:all')

        this.socketService.onNewWorkflow()
          .subscribe((message) => {
            this.getWorkflows(this.page, this.pageSize, this.parameters)
          })

        this.socketService.onDeleteWorkflow()
          .subscribe((message) => {
            this.getWorkflows(this.page, this.pageSize, this.parameters)
          })

        this.socketService.onRetryJob()
          .subscribe((message) => {
            this.getWorkflows(this.page, this.pageSize, this.parameters)
          })
      })
  }

  ngOnDestroy() {
    if (this.sub) {
      this.sub.unsubscribe()
    }
    for (let connection of this.connections) {
      connection.unsubscribe()
    }
  }

  newOrder() {
    this.router.navigate(['/orders/new'])
  }

  goToWorkflow(workflow: Workflow) {
    if (this.authService.hasTechnicianRight()) {
      this.router.navigate([`/workflows/${workflow.id}`])
    }
  }

  getWorkflows(page: number, pageSize: number, parameters: WorkflowQueryParams) {
    this.workflowService.getWorkflows(
      page,
      pageSize,
      parameters,
      this.selectedMode
    ).subscribe(workflowPage => {
      if (workflowPage === undefined) {
        this.length = undefined
        this.workflows = new WorkflowPage()
        return
      }

      this.workflows = workflowPage
      this.length = workflowPage.total
      this.loading = false
      for (let workflow of this.workflows.data) {
        var connection = this.socketService.onWorkflowUpdate(workflow.id)
          .subscribe((message: Message) => {
            this.updateWorkflow(message.body.workflow_id)
          })
      }
    })
  }

  eventGetWorkflows(event) {
    this.pageSize = event.pageSize
    this.router.navigate(['/orders'], { queryParams: this.getQueryParamsForPage(event.pageIndex, event.pageSize) })
    this.getWorkflows(event.pageIndex, event.pageSize, this.parameters)
  }

  updateWorkflow(workflow_id) {
    this.workflowService.getWorkflow(workflow_id)
      .subscribe(workflowData => {
        for (let i = 0; i < this.workflows.data.length; i++) {
          if (this.workflows.data[i].id === workflowData.data.id) {
            this.workflows.data[i] = workflowData.data
            return
          }
        }
      })
  }

  getQueryParamsForPage(pageIndex: number, pageSize: number = undefined): Object {
    var params = {}
    if (pageIndex !== 0) {
      params['page'] = pageIndex
    }
    if (pageSize) {
      if (pageSize !== 10) {
        params['per_page'] = pageSize
      }
    } else {
      if (this.pageSize !== 10) {
        params['per_page'] = this.pageSize
      }
    }
    if (this.reference !== '') {
      params['reference'] = this.reference
    }
    if (this.order_id !== undefined) {
      params['order_id[]'] = this.order_id
    }

    return params
  }

  source_link(workflow) {
    if (workflow.artifacts.length > 0) {
      const mp4_path = this.getDestinationFilename(workflow, "mp4");
      const ttml_path = this.getDestinationFilename(workflow, ".ttml", ["synchronised.ttml", "file_positioned.ttml"]);
      this.openLink(mp4_path, ttml_path)
    }
  }

  sync_link(workflow, filename) {
    if (workflow.artifacts.length > 0) {
      const mp4_path = this.getDestinationFilename(workflow, "mp4");
      const ttml_path = this.getDestinationFilename(workflow, filename);
      this.openLink(mp4_path, ttml_path)
    }
  }

  private playS3Media(directory, filename) {
    this.s3Service.getConfiguration().subscribe(response => {
      const manifest_path = response.vod_endpoint + "/" + response.bucket + "/" + directory + "/" + filename + "/manifest.mpd"
      const full_url = "http://cathodique.magneto.build.ftven.net/?env=prod&src=%5B%22" + manifest_path + "%22%5D"
      window.open(full_url, "_blank");
    });
  }

  private playS3MediaFromPath(path) {
    const filename = path.substring(path.lastIndexOf('/') + 1);
    const directory = path.substring(0, path.lastIndexOf('/') + 1);
    this.playS3Media(directory, filename);
  }

  play_original_version(workflow) {
    if (workflow.artifacts.length > 0) {
      const original_mp4_path = this.getDestinationFilename(workflow, "mp4", ["enhanced.mp4"]);
      this.playS3MediaFromPath(original_mp4_path);
    }
  }

  play_enhanced_version(workflow) {
    if (workflow.artifacts.length > 0) {
      const enhanced_mp4_path = this.getDestinationFilename(workflow, "enhanced.mp4");
      this.playS3MediaFromPath(enhanced_mp4_path);
    }
  }

  openLink(mp4_path, ttml_path) {
    const mp4_file_name = mp4_path.substring(mp4_path.lastIndexOf('/') + 1);
    const ttml_file_name = ttml_path.substring(ttml_path.lastIndexOf('/') + 1);
    const directory = ttml_path.substring(0, ttml_path.lastIndexOf('/') + 1);

    this.s3Service.getConfiguration().subscribe(response => {
      const manifest_path = response.vod_endpoint + "/" + response.bucket + "/" + directory + "," + mp4_file_name + "," + ttml_file_name + ",.urlset/manifest.mpd"
      const full_url = "http://cathodique.magneto.build.ftven.net/?gitrefname=poc/subtil/ttml_rendering&env=prod&src=%5B%22" + manifest_path + "%22%5D"

      window.open(full_url, "_blank");
    });
  }

  downloadS3Resource(workflow: Workflow, filename: string) {
    if (workflow.artifacts.length > 0) {
      const file_path = this.getDestinationFilename(workflow, filename);
      const current = this

      if (file_path) {
        this.s3Service.getPresignedUrl(file_path).subscribe(response => {
          current.downloadFileUrl(response.url)
        });
      }
    }
  }

  viewTranscript(workflow: Workflow) {
    this.router.navigate(['orders', workflow.id, 'transcript'])
  }

  viewNlp(workflow: Workflow) {
    this.router.navigate(['orders', workflow.id, 'nlp'])
  }

  getDestinationFilename(workflow, extension: string, notExtension?: string[]) {
    const result = workflow.jobs.filter(job => {
      if ((job.name == "job_transfer" || job.name == "job_transfer_optim")) {
        const parameter = job.params.filter(param => param.id === "destination_path");
        if (parameter.length > 0) {
          const sourceFilename = parameter[0].value;
          if (notExtension) {
            const notExtensionMatch = notExtension.filter(extension => sourceFilename.endsWith(extension)).length;
            return (sourceFilename.endsWith(extension) && (notExtensionMatch === 0))
          } else {
            return sourceFilename.endsWith(extension)
          }
        } else {
          return false
        }
      } else {
        return false
      }
    });

    if (result.length == 0) {
      return undefined
    }

    return result[0].params.filter(param => param.id === "destination_path")[0].value;
  }

  downloadFileUrl(path: string) {
    var element = document.createElement('a');
    element.setAttribute('href', path);

    element.style.display = 'none';
    document.body.appendChild(element);
    element.click();
    document.body.removeChild(element);
  }

  getCompletedPercentage(workflow) {
    const total_tasks = workflow.steps.length
    var completed_tasks = 0

    for (var i = 0; i < workflow.steps.length; ++i) {
      const step = workflow.steps[i]
      if (step.jobs.total != 0) {
        if (step.jobs.completed == step.jobs.total) {
          completed_tasks += 1
        }
      }
    }

    return completed_tasks / total_tasks * 100
  }
}
