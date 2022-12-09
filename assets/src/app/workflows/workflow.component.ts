import { Component, EventEmitter, Input, Output } from '@angular/core'
import { MatDialog } from '@angular/material/dialog'
import { Subscription } from 'rxjs'

import { AuthService } from '../authentication/auth.service'
import { UserService } from '../services/user.service'
import { Workflow } from '../models/workflow'

@Component({
  selector: 'workflow-component',
  templateUrl: 'workflow.component.html',
  styleUrls: ['./workflow.component.less'],
})
export class WorkflowComponent {
  private readonly subscriptions = new Subscription()

  @Input() workflow: Workflow
  @Input() detailed = false

  // This refreshEvent allows direct refresh when modifying a workflow through the page
  @Output() refreshEvent = new EventEmitter()

  first_name: string
  last_name: string
  user_name: string

  right_retry = false

  constructor(
    private authService: AuthService,
    private userService: UserService,
    public dialog: MatDialog,
  ) {}

  ngOnChanges() {
    this.workflow = Object.assign(new Workflow(), this.workflow)
  }

  ngOnInit() {
    this.workflow = Object.assign(new Workflow(), this.workflow)
    this.userService
      .getUserByUuid(this.workflow.user_uuid)
      .subscribe((response) => {
        this.user_name = response.data.email
        if (response.data.first_name && response.data.last_name) {
          this.first_name = response.data.first_name
          this.last_name = response.data.last_name
          this.user_name = response.data.username
        }
      })
  }

  switchDetailed(): void {
    this.detailed = !this.detailed
    if (this.workflow !== undefined && this.detailed) {
      this.authService
        .hasAnyRights('workflow::' + this.workflow.identifier, 'retry')
        .subscribe((response) => {
          this.right_retry = response.authorized
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
