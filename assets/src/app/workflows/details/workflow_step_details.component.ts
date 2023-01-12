import { Component, EventEmitter, Input, Output } from '@angular/core'
import { Step, Workflow } from '../../models/workflow'

@Component({
  selector: 'workflow-step-details-component',
  templateUrl: 'workflow_step_details.component.html',
  styleUrls: ['./workflow_step_details.component.less'],
})
export class WorkflowStepDetailsComponent {
  details_opened = false
  disabled = true
  workflow_mode = false

  @Input() step: Step
  @Input() workflow: Workflow

  @Output() stepChange = new EventEmitter<Step>()

  ngOnInit() {
    this.details_opened = this.step.focus || false

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
      this.step.focus = this.details_opened
      this.stepChange.emit(this.step)
      if (
        ['workflow_one_for_one', 'workflow_one_for_many'].includes(
          this.step.mode,
        )
      ) {
        this.workflow_mode = true
      }
      console.log(this.step)
      console.log(this.workflow)
    }
  }
}
