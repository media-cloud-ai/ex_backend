
import {Component, Input} from '@angular/core'
import {Step, Workflow} from '../../models/workflow'

@Component({
  selector: 'workflow-step-details-component',
  templateUrl: 'workflow_step_details.component.html',
  styleUrls: ['./workflow_step_details.component.less']
})

export class WorkflowStepDetailsComponent {
  details_opened = false
  disabled: boolean = true

  @Input() step: Step
  @Input() workflow: Workflow

  ngOnInit() {
    if (this.step.parameters) {
      this.disabled = this.step.parameters.length === 0
    }

    if (this.step.jobs && this.step.jobs.total !== undefined && this.disabled) {
      this.disabled = this.step.jobs.total === 0
    }
  }

  toggleStepDetails(): void {
    if (!this.disabled) {
      this.details_opened = !this.details_opened
    }
  }
}
