
import {Component} from '@angular/core'
import {ActivatedRoute, Router} from '@angular/router'
import {MatDialog} from '@angular/material/dialog'

import {Message} from '../models/message'
import {SocketService} from '../services/socket.service'
import {WorkerService} from '../services/worker.service'
import {WorkflowService} from '../services/workflow.service'

import {Worker, WorkerStatus} from '../models/worker'

@Component({
  selector: 'workers-component',
  templateUrl: 'workers.component.html',
  styleUrls: ['workers.component.less']
})

export class WorkersComponent {
  connection: any
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

        this.workerService.getWorkerStatuses()
        .subscribe(workerStatuses => {
          if(workerStatuses) {
            this.workers_status = workerStatuses.data;
          }
        })

        this.socketService.initSocket()
        this.socketService.connectToChannel('notifications:all')

        this.connection = this.socketService.onWorkersStatusUpdated()
          .subscribe((message: Message) => {
            this.workers_status = [];

            var workers_status = message.body.content.data;
            Object.entries(workers_status).forEach(
              ([id, status]) => {
                let worker_status = Object.assign(new WorkerStatus(), status);
                this.workers_status.push(worker_status);
              }
            );
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
}
