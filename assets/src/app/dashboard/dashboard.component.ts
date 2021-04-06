
import { Component } from '@angular/core'
import { formatDate, registerLocaleData } from '@angular/common'
import localeFr from '@angular/common/locales/fr';
import { AuthService } from '../authentication/auth.service'
import { Subscription } from 'rxjs'

import * as CanvasJS from '../../assets/canvasjs.min.js';

import { ApplicationService } from '../services/application.service'
import { WorkflowService } from '../services/workflow.service'
import { Application } from '../models/application'

import { WorkflowHistory, WorkflowQueryParams } from '../models/page/workflow_page'

registerLocaleData(localeFr, 'fr');

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

  colors = {
    error: "#ff3719",
    completed: "#87b209",
    processing: "#3864AA"
  }

  parameters: WorkflowQueryParams;

  loading = true

  constructor(
    private applicationService: ApplicationService,
    private workflowService: WorkflowService,
    public authService: AuthService
  ) {
    let today = new Date();
    let yesterday = new Date();
    yesterday.setDate(today.getDate() - 1);
    this.parameters =  {
      identifiers: [],
      start_date: yesterday,
      end_date: today,
      status: [
        "completed",
        "error"
      ],
      detailed: false,
      time_interval: 1
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
    this.loading = true
    this.workflowService.getWorkflowStatistics(parameters)
      .subscribe(response => {
        let data = parameters.status.map(state => (
          this.generateDatapoints(response, state)))
        let chart = new CanvasJS.Chart("chartContainer", {
          data: data,
          options: {},
          axisX:{
            valueFormatString: "YYYY-MM-DD HH:mm",
          }
        })
        this.loading = false

        chart.render()
      })
  }

  generateDatapoints(history: WorkflowHistory, status: string) {
    return {
      type: "line",
      xValueType: "dateTime",
      name: status,
      color: this.colors[status],
      showInLegend: true,
      dataPoints: history.data.bins.map(bin => ({
        x: new Date(bin.end_date)
        y: bin[status]
      }))
    }
  }
}
