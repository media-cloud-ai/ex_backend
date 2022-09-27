
import { Component } from '@angular/core'
import { registerLocaleData } from '@angular/common'
import localeFr from '@angular/common/locales/fr';
import { AuthService } from '../authentication/auth.service'
import { Subscription } from 'rxjs'

import { ApplicationService } from '../services/application.service'
import { WorkflowService } from '../services/workflow.service'
import { Application } from '../models/application'

import { WorkflowQueryParams } from '../models/page/workflow_page'

import { Chart } from 'angular-highcharts';

registerLocaleData(localeFr, 'fr');

@Component({
  selector: 'dashboard-component',
  templateUrl: 'dashboard.component.html',
  styleUrls: ['./dashboard.component.less']
})

export class DashboardComponent {
  public categories = [];
  public historyChart: Chart;

  right_administrator: boolean
  right_technician: boolean
  right_editor: boolean
  application: Application

  subIn: Subscription
  subOut: Subscription

  series = ["error", "completed", "pending", "processing"];

  colors = {
    error: "#FF3719",
    completed: "#87b209",
    pending: "#88497e",
    processing: "#3864AA"
  }

  parameters: WorkflowQueryParams;

  constructor(
    private applicationService: ApplicationService,
    private workflowService: WorkflowService,
    public authService: AuthService,
  ) {
    let today = new Date();
    let yesterday = new Date();
    yesterday.setDate(today.getDate() - 1);

    this.parameters = {
      identifiers: [],
      selectedDateRange: {
        startDate: yesterday,
        endDate: today,
      },
      mode: [
        "file",
        "live"
      ],
      status: [
        "completed",
        "error"
      ],
      detailed: false,
      time_interval: 3600
    };
  }

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

    this.drawHistoryChart();
  }

  drawHistoryChart(data?): void {

    let x_labels = [];
    let series = {
      completed: [],
      error: [],
      pending: [],
      processing: [],
    }

    this.historyChart = new Chart({
      chart: {
          type: 'column',
      },
      title: {
          text: '',
      },
      xAxis: {
        labels: {
          formatter: function() {
            return this.value.slice(0, 16);
          }
        },
      },
      yAxis: {
          min: 0,
          title: {
              text: 'Count of workflows'
          },
          stackLabels: {
              enabled: true,
              style: {
                  fontWeight: 'bold',
                  color: 'gray',
                  textOutline: 'none'
              }
          },
          allowDecimals: false
      },
      tooltip: {
          headerFormat: '<b>{point.x}</b><br/>',
          pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}'
      },
      plotOptions: {
          column: {
              stacking: 'normal',
              dataLabels: {
                  enabled: true
              }
          }
      }
    });

    if (data != undefined) {
      data.bins.reverse().map(bin => {
        x_labels.push(bin["start_date"])
        for (let s of this.series){
          series[s].push(bin[s])
        }
      })

      this.historyChart.options.xAxis.categories = x_labels;

      for (let s of this.series){
        if (this.parameters.status.includes(s)) {
          this.historyChart.addSeries({
            name: s,
            data: series[s],
            color: this.colors[s]
          }, true, true)
        }
      }
    }
  }

  rangeChanged(event){
    this.parameters.time_interval = parseInt(event.value)
    this.updateWorkflows(this.parameters)
  }

  updateWorkflows(parameters: WorkflowQueryParams) {
    this.parameters = parameters
    
    this.workflowService.getWorkflowStatistics(parameters)
      .subscribe(response => {
        this.historyChart.destroy();
        this.drawHistoryChart(response.data);
      })
  }
}
