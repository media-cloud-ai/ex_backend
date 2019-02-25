
import {Component} from '@angular/core'
import {AuthService}    from '../authentication/auth.service'
import {Subscription}   from 'rxjs'

import * as CanvasJS from 'canvasjs/dist/canvasjs.min.js';

import {ApplicationService} from '../services/application.service'
import {WorkflowService} from '../services/workflow.service'
import {Application} from '../models/application'

@Component({
    selector: 'dashboard-component',
    templateUrl: 'dashboard.component.html',
})

export class DashboardComponent {
  right_administrator: boolean
  right_technician: boolean
  right_editor: boolean
  application: Application

  subIn: Subscription
  subOut: Subscription

  constructor(
    private applicationService: ApplicationService,
    private workflowService: WorkflowService,
    public authService: AuthService
  ) {}

  ngOnInit() {
    this.subIn = this.authService.userLoggedIn$.subscribe(
      username => {
        this.right_administrator = this.authService.hasAdministratorRight()
        this.right_technician = this.authService.hasTechnicianRight()
        this.right_editor = this.authService.hasEditorRight()
      })
    this.subOut = this.authService.userLoggedOut$.subscribe(
      username => {
        delete this.right_administrator
        delete this.right_technician
        delete this.right_editor
      })

    if (this.authService.isLoggedIn) {
      this.right_administrator = this.authService.hasAdministratorRight()
      this.right_technician = this.authService.hasTechnicianRight()
      this.right_editor = this.authService.hasEditorRight()
    }

    this.applicationService.get()
    .subscribe(application => {
      this.application = application
    })

    this.workflowService.getWorkflowStatistics("hour")
    .subscribe(stats => {
      const total = stats.data.map((item, index) => {
        item['y'] = item['total']
        item['x'] = -index
        return item
      });

      let chart = new CanvasJS.Chart("chartContainer", {
        // animationEnabled: true,
        // exportEnabled: false,
        // zoomEnabled: true,
        // title: {
        //   text: "Workflow history"
        // },
        data: [
          {
            type: 'line',
            name: "Total",
            dataPoints: total
          },
          // {
          //   type: 'line',
          //   name: "Error",
          //   dataPoints: [ {y: 6}, {y: 5}, {y: 8}, {y: 8}, {y: 5}, {y: 5}, {y: 4} ]
          // }
        ],
        options: {}
      });
        
      chart.render();
    })
  }
}
