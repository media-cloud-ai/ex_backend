
import {Component} from '@angular/core'
import {ActivatedRoute, Router} from '@angular/router'
import {MatDialog} from '@angular/material/dialog'

import {WorkerService} from '../services/worker.service'

import {Worker} from '../models/worker'

@Component({
  selector: 'workers-component',
  templateUrl: 'workers.component.html',
  styleUrls: ['workers.component.less']
})

export class WorkersComponent {
  workers: Worker[]
  selectedStatus = []
  sub = undefined;

  status = [
    {id: 'initializing', label: 'Initializing'},
    {id: 'started', label: 'Started'},
    {id: 'terminated', label: 'Terminated'},
  ]

  constructor(
    private workerService: WorkerService,
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
}
