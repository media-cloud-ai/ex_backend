
import {Component, Input} from '@angular/core';
import {Step} from '../../models/workflow';

@Component({
  selector: 'workflow-step-details-component',
  templateUrl: 'workflow_step_details.component.html',
  styleUrls: ['./workflow_step_details.component.less']
})

export class WorkflowStepDetailsComponent {
  details_opened = false;

  @Input() step: Step;
  @Input() workflowId: number;

  constructor(
  ) { }

  ngOnInit() {
    console.log("this.step", this.step);
  }

  toggleStepDetails(): void {
    this.details_opened = !this.details_opened;
  }

}
