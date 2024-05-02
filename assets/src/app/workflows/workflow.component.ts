import { Component, EventEmitter, Input, Output } from '@angular/core'
import { MatDialog } from '@angular/material/dialog'
import { Subscription } from 'rxjs'

import * as moment from 'moment'

import { AuthService } from '../authentication/auth.service'
import { UserPage } from '../models/page/user_page'
import { UserService } from '../services/user.service'
import { Workflow } from '../models/workflow'
import { WorkflowQueryParams } from '../models/page/workflow_page'
import { WorkflowDuration } from '../models/statistics/duration'
import { StatisticsService } from '../services/statistics.service'
import { User } from '../models/user'

@Component({
  selector: 'workflow-component',
  templateUrl: 'workflow.component.html',
  styleUrls: ['./workflow.component.less'],
})
export class WorkflowComponent {
  private readonly subscriptions = new Subscription()

  @Input() workflow: Workflow
  @Input() parameters: WorkflowQueryParams
  @Input() detailed = false

  // This refreshEvent allows direct refresh when modifying a workflow through the page
  @Output() refreshEvent = new EventEmitter()

  first_name: string
  last_name: string
  user_name: string

  right_retry = false

  duration: WorkflowDuration = undefined
  end_date: string = undefined

  constructor(
    private authService: AuthService,
    private userService: UserService,
    private statisticsService: StatisticsService,
    public dialog: MatDialog,
  ) {}

  ngOnChanges() {
    this.workflow = Object.assign(new Workflow(), this.workflow)
  }

  ngOnInit() {
    this.workflow = Object.assign(new Workflow(), this.workflow)

    if (this.workflow.user) {
      this.setUserDetails(this.workflow.user)
    } else {
      this.userService
        .getUserByUuid(this.workflow.user_uuid)
        .subscribe((response) => {
          if (response.data) {
            this.setUserDetails(response.data)
          }
        })
    }

    if (this.workflow.durations) {
      this.setDurationsDetails(this.workflow.durations)
    } else {
      this.statisticsService
        .getWorkflowDurations(this.workflow.id)
        .subscribe((response) => {
          if (response && response.data.length > 0) {
            this.setDurationsDetails(response.data[0])
          }
        })
    }
  }

  setDurationsDetails(workflowDuration: WorkflowDuration): void {
    this.duration = workflowDuration

    if (this.workflow.has_ended()) {
      this.end_date = moment
        .utc(this.workflow.created_at)
        .add(this.duration.total, 'seconds')
        .toISOString()
    }
  }

  setUserDetails(user: User): void {
    this.user_name = user.email
    if (user.first_name && user.last_name) {
      this.first_name = user.first_name
      this.last_name = user.last_name
      this.user_name = user.username
    }
  }

  switchDetailed(): void {
    this.detailed = !this.detailed
    if (this.workflow !== undefined && this.detailed) {
      this.authService
        .hasAnyRights('workflow::' + this.workflow.identifier, ['retry'])
        .subscribe((response) => {
          this.right_retry = response.authorized['retry']
        })
    }
  }

  getStepsCount(): number {
    let count = 0
    for (const step of this.workflow.steps) {
      if (
        step.jobs.skipped > 0 ||
        step.jobs.completed > 0 ||
        step.jobs.errors > 0
      ) {
        count++
      }
    }
    return count
  }

  getTotalSteps(): number {
    return this.workflow.steps.length
  }

  refreshWorkflows(): void {
    this.refreshEvent.emit()
  }
}
