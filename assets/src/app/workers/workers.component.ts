
import {Component} from '@angular/core'
import {ActivatedRoute, Router} from '@angular/router'
import {MatDialog} from '@angular/material/dialog'

import * as moment from 'moment'
import {Moment} from 'moment'

import {Message} from '../models/message'
import {SocketService} from '../services/socket.service'
import {WorkerService} from '../services/worker.service'
import {WorkflowService} from '../services/workflow.service'

import {Worker, WorkerStatus} from '../models/worker'

const OUTDATE_SECONDS_THRESHOLD = 3600;

@Component({
  selector: 'workers-component',
  templateUrl: 'workers.component.html',
  styleUrls: ['workers.component.less']
})
export class WorkersComponent {
  // paginator parameters
  length = 1000
  page = 0
  pageSize = 10
  pageSizeOptions = [
    10,
    20,
    50,
    100
  ]

  connection: any
  loading: boolean
  last_worker_status_update: Moment
  workers: Worker[]
  workers_status: WorkerStatus[]
  selectedStatus = []
  sub = undefined;

  status = [
    {id: 'initializing', label: 'Initializing'},
    {id: 'started', label: 'Started'},
    {id: 'terminated', label: 'Terminated'},
  ]

  constructor(
    private socketService: SocketService,
    private workerService: WorkerService,
    private workflowService: WorkflowService,
    private route: ActivatedRoute,
    private router: Router,
    private dialog: MatDialog
  ) {
  }

  ngOnInit() {
    this.loading = true;
    this.sub = this.route
      .queryParams
      .subscribe(params => {
        var status = params['status[]']
        if (status && !Array.isArray(status)){
          status = [status]
        }
        if (status) {
          this.selectedStatus = status
        }

        this.workerService.getWorkers(this.selectedStatus)
        .subscribe(workerPage => {
          if(workerPage) {
            this.workers = workerPage.data
          }
        })

        this.getWorkerStatuses()

        this.socketService.initSocket()
        this.socketService.connectToChannel('notifications:all')

        this.connection = this.socketService.onWorkersStatusUpdated()
          .subscribe((message: Message) => {
            this.getWorkerStatuses();
          })
      });
  }

  ngOnDestroy() {
    if (this.sub) {
      this.sub.unsubscribe()
    }
  }

  public updateSearch() {
    this.router.navigate(['/workers'], { queryParams: this.getQueryParams() })
  }

  private getQueryParams(): Object {
    var params = {}

    if (this.selectedStatus.length > 0) {
      params['status[]'] = this.selectedStatus
    }

    return params
  }

  private getWorkerStatuses() {
    this.loading = true;
    this.workerService.getWorkerStatuses(this.page, this.pageSize)
        .subscribe(workerStatuses => {
          this.length = undefined;
          if(workerStatuses) {
            this.length = workerStatuses.total;
            this.workers_status = workerStatuses.data;
            this.last_worker_status_update = moment.utc();
          }
          this.loading = false;
        })
  }

  isWorkerStatusOutdated(worker_status: WorkerStatus) {
    let status_update = moment(worker_status.updated_at);
    let diff = this.last_worker_status_update.diff(status_update);
    let diff_seconds = moment.duration(diff).asSeconds();
    return diff_seconds > OUTDATE_SECONDS_THRESHOLD;
  }

  getUpdateStatusClass(worker_status: WorkerStatus) {
    return this.isWorkerStatusOutdated(worker_status) && worker_status.activity != "Terminated" ? "outdated": "up-to-date";
  }

  public stopProcess(id, job_id) {
    let message = {
      "job_id": job_id,
      "type": "stop_process",
      "parameters": []
    }

    this.workerService.sendWorkerOrderMessage(id, message)
      .subscribe(result => {});
  }

  public toggleJobConsumption(id, prefix) {
    let message = {
      "type": prefix + "_consuming_jobs"
    }

    this.workerService.sendWorkerOrderMessage(id, message)
      .subscribe(result => {});
  }

  public stopWorker(id) {
    let message = {
      "type": "stop_worker"
    }

    this.workerService.sendWorkerOrderMessage(id, message)
      .subscribe(result => {});
  }

  public goToWorkflow(jobId) {
    this.workflowService.getWorkflowForJob(jobId, "simple")
      .subscribe(workflow => {
        console.log("Workflow:", workflow);
        this.router.navigate([`/workflows/${workflow.data.id}`]);
      });
  }

  changeWorkerStatusPage(event) {
    this.page = event.pageIndex;
    this.pageSize = event.pageSize;
    this.getWorkerStatuses();
  }
}
