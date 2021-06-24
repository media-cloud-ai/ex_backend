
import { Component } from '@angular/core'
import { registerLocaleData } from '@angular/common'
import localeFr from '@angular/common/locales/fr';
import { AuthService } from '../authentication/auth.service'
import { Subscription } from 'rxjs'

import { ApplicationService } from '../services/application.service'
import { WorkflowService } from '../services/workflow.service'
import { Application } from '../models/application'

import { WorkflowHistory, WorkflowQueryParams } from '../models/page/workflow_page'



import { ChartDataSets, ChartOptions } from 'chart.js';
import { Label } from 'ng2-charts';


registerLocaleData(localeFr, 'fr');

@Component({
  selector: 'dashboard-component',
  templateUrl: 'dashboard.component.html',
  styleUrls: ['./dashboard.component.less'],
})

export class DashboardComponent {
  public lineChartData: ChartDataSets[];
  public lineChartLabels: Label[];
  public lineChartOptions: ChartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    scales: {
      xAxes: [{
        type: 'time',
        time: {
          displayFormats: {
            minute: "YYYY-MM-DD HH:mm"
          },
          parser: "YYYY-MM-DD HH:mm:SS"
        }
      }]
    }
  };
  public lineChartLegend = true;
  public lineChartType = 'line';
  public lineChartPlugins = [];


  right_administrator: boolean
  right_technician: boolean
  right_editor: boolean
  application: Application

  subIn: Subscription
  subOut: Subscription

  colors = {
    error: "#ff3719",
    completed: "#87b209",
    pending: "#88497e",
    processing: "#3864AA"
  }

  parameters: WorkflowQueryParams;

  data: any;

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
      start_date: yesterday,
      end_date: today,
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

    this.updateWorkflows(this.parameters)
  }

  updateWorkflows(parameters: WorkflowQueryParams) {
    this.lineChartData = undefined
    this.workflowService.getWorkflowStatistics(parameters)
      .subscribe(response => {
        this.lineChartData = parameters.status.map(state => (
          {
            label: state,
            fill: false,
            borderColor: this.colors[state],
            backgroundColor: this.colors[state],
            pointBorderColor: this.colors[state],
            pointBackgroundColor: this.colors[state],
            data: response.data.bins.map(bin => ({
              y: bin[state],
              t: bin.end_date
            }))
          }));
        this.lineChartLabels = response.data.bins.map(bin => (bin.end_date));
      })
  }
}
