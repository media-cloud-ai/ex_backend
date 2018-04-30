
import {Component, Input} from '@angular/core';
import {Workflow} from '../../models/workflow';

import * as moment from 'moment';

@Component({
  selector: 'duration-component',
  templateUrl: 'duration.component.html',
})

export class DurationComponent {
  duration = undefined;

  @Input() workflow: Workflow;

  constructor(
  ) {}

  ngOnInit() {
    if(this.workflow.artifacts[0]) {
      let start_moment = moment(this.workflow.created_at)
      let end_moment = moment(this.workflow.artifacts[0]["inserted_at"])

      this.duration = end_moment.diff(start_moment);
    } else {
      this.duration = undefined;
    }
  }
}
