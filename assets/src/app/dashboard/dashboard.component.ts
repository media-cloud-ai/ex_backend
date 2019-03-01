
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
      var totalData = []
      var rosettaData = []
      var rdfData = []
      var dashData = []
      var acsData = []

      let suffix = "h"
      if(this.selectedScale == "minute") {
        suffix = "m"
      }
      if(this.selectedScale == "day") {
        suffix = "d"
      }

      for(var index = 0; index < stats.data.length; ++index) {
        totalData.push({
          x: -index,
          y: stats.data[index]['total']
        })
        rosettaData.push({
          x: -index,
          y: stats.data[index]['rosetta']
        })
        rdfData.push({
          x: -index,
          y: stats.data[index]['ingest_rdf']
        })
        dashData.push({
          x: -index,
          y: stats.data[index]['ingest_dash']
        })
        acsData.push({
          x: -index,
          y: stats.data[index]['process_acs']
        })
      }

      let chart = new CanvasJS.Chart("chartContainer", {
        // animationEnabled: true,
        // exportEnabled: false,
        // zoomEnabled: true,
        // title: {
        //   text: "Workflow history"
        // },

        // legend: {
        //   horizontalAlign: "left", // "center" , "right"
        //   verticalAlign: "center",  // "top" , "bottom"
        //   fontSize: 15
        // },
        backgroundColor: "#ffffff00",
        data: [
          {
            type: 'line',
            name: "Total",
            toolTipContent: "<b>{name}</b>: {y}",
            dataPoints: totalData
          },
          {
            type: 'line',
            name: "Rosetta",
            toolTipContent: "<b>{name}</b>: {y}",
            dataPoints: rosettaData
          },
          {
            type: 'line',
            name: "Ingest RDF",
            toolTipContent: "<b>{name}</b>: {y}",
            dataPoints: rdfData
          },
          {
            type: 'line',
            name: "DASH Ingest",
            toolTipContent: "<b>{name}</b>: {y}",
            dataPoints: dashData
          },
          {
            type: 'line',
            name: "ACS Process",
            toolTipContent: "<b>{name}</b>: {y}",
            dataPoints: acsData
          },
        ],
        axisX: {
            suffix: suffix
        },
        options: {}
      });
        
      chart.render();
    })
  }
}
