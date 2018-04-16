
import {Component, Input} from '@angular/core';
import {Workflow} from '../models/workflow';

@Component({
  selector: 'workflow-component',
  templateUrl: 'workflow.component.html',
  styleUrls: ['./workflow.component.less'],
})

export class WorkflowComponent {
  jobs_opened: boolean = false;
  @Input() workflow: Workflow[];

  constructor(
  ) {}

  openJobs() : void {
    this.jobs_opened = true;
  }
  closeJobs() : void {
    this.jobs_opened = false;
  }
}
