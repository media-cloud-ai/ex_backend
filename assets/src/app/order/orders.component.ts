
import {Component} from '@angular/core'
import {ActivatedRoute, Router} from '@angular/router'

import {SocketService} from '../services/socket.service'
import {S3Service} from '../services/s3.service'
import {WorkflowService} from '../services/workflow.service'
import {WorkflowPage} from '../models/page/workflow_page'
import {Workflow} from '../models/workflow'

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

  selectedStatus = [
    'completed',
    'error',
    'processing',
  ]
  selectedWorkflows = [
    'FranceTélévisions ACS (standalone)'
  ]
  workflows: WorkflowPage
  connections: any = []

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private socketService: SocketService,
    private workflowService: WorkflowService,
    private s3Service: S3Service,
  ) {}

  ngOnInit() {
    this.sub = this.route
      .queryParams
      .subscribe(params => {
        this.page = +params['page'] || 0
        this.pageSize = +params['per_page'] || 10
        this.reference = params['reference']
        this.order_id = params['order_id']
        this.getWorkflows()

        this.socketService.initSocket()
        this.socketService.connectToChannel('notifications:all')

        this.socketService.onNewWorkflow()
          .subscribe((message) => {
            this.getWorkflows()
          })

        this.socketService.onDeleteWorkflow()
          .subscribe((message) => {
            this.getWorkflows()
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

  getWorkflows() {
    for (let connection of this.connections) {
      connection.unsubscribe()
    }
    this.loading = true

    this.workflowService.getWorkflows(
      this.page,
      this.pageSize,
      this.reference,
      this.selectedStatus,
      this.selectedWorkflows,
      [this.order_id],
      this.after_date,
      this.before_date)
    .subscribe(workflowPage => {
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
          .subscribe((message) => {
            this.updateWorkflow(message.body.workflow_id)
          })
      }
    })
  }

  eventGetWorkflows(event) {
    this.pageSize = event.pageSize
    this.router.navigate(['/orders'], { queryParams: this.getQueryParamsForPage(event.pageIndex, event.pageSize) })
    this.getWorkflows()
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
    if (this.selectedStatus.length != 3) {
      params['status[]'] = this.selectedStatus
    }
    if (this.selectedWorkflows.length !== 4) {
      params['workflows[]'] = this.selectedWorkflows
    }
    if (this.order_id !== undefined) {
      params['order_id[]'] = this.order_id
    }

    return params
  }

  source_link(workflow) {
    if(workflow.artifacts.length > 0) {
      const mp4_path = this.getDestinationFilename(workflow, "mp4");
      const ttml_path = this.getDestinationFilename(workflow, ".ttml", "synchronised.ttml");
      this.openLink(mp4_path, ttml_path)
    }
  }

  sync_link(workflow) {
    if(workflow.artifacts.length > 0) {
      const mp4_path = this.getDestinationFilename(workflow, "mp4");
      const ttml_path = this.getDestinationFilename(workflow, "synchronised.ttml");
      this.openLink(mp4_path, ttml_path)
    }
  }

  openLink(mp4_path, ttml_path) {
    const mp4_file_name = mp4_path.substring(mp4_path.lastIndexOf('/') + 1);
    const ttml_file_name = ttml_path.substring(ttml_path.lastIndexOf('/') + 1);
    const directory = ttml_path.substring(0, ttml_path.lastIndexOf('/') + 1);

    this.s3Service.getConfiguration().subscribe(response => {
      console.log(response)

      const manifest_path = response.vod_endpoint + "/" + response.bucket + "/" + directory + "," + mp4_file_name + "," + ttml_file_name + ",.urlset/manifest.mpd"
      const full_url = "http://cathodique.magneto.build.ftven.net/?gitrefname=poc/subtil/ttml_rendering&options=%7B%22autostart%22%3Afalse%2C%22showAd%22%3Afalse%7D&env=integ&src=%5B%22" + manifest_path + "%22%5D"

      window.open(full_url, "_blank");
    });
  }

  downloadTtml(workflow) {
    if(workflow.artifacts.length > 0) {
      const ttml_path = this.getDestinationFilename(workflow, "synchronised.ttml");
      const current = this
      this.s3Service.getPresignedUrl(ttml_path).subscribe(response => {
        current.downloadFileUrl(response.url)
      });
    }
  }

  getDestinationFilename(workflow, extension: string, not_extension?: string) {
    const result = workflow.jobs.filter(job => {
      if(job.name == "job_transfer"){
        const parameter = job.params.filter(param => param.id === "destination_path");
        if(parameter.length == 1) {
          if(not_extension) {
            return parameter[0].value.endsWith(extension) && !parameter[0].value.endsWith(not_extension)
          } else {
            return parameter[0].value.endsWith(extension)
          }
        } else {
          return false
        }
      } else {
        return false
      }
    });

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

    for(var i = 0; i < workflow.steps.length; ++i) {
      const step = workflow.steps[i]
      if(step.jobs.total != 0) {
        if(step.jobs.completed == step.jobs.total) {
          completed_tasks += 1
        }
      }
    }

    return completed_tasks / total_tasks * 100
  }
}
