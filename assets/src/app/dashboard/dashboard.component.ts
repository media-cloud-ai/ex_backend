
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
    styleUrls: ['./dashboard.component.less'],
})

export class DashboardComponent {
  right_administrator: boolean
  right_technician: boolean
  right_editor: boolean
  application: Application

  subIn: Subscription
  subOut: Subscription

  selectedScale: string = "hour"
  scales = [
    {
      id: "minute",
      label: "Minutes"
    },
    {
      id: "hour",
      label: "Hours"
    },
    {
      id: "day",
      label: "Days"
    }
  ]

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

    this.renderChart("hour")
  }

  updateScale(event) {
    this.renderChart(this.selectedScale)
  }

  renderChart(scale) {
    this.workflowService.getWorkflowStatistics(scale)
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
        backgroundColor: "#ffffff00",
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
