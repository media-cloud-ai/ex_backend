
import {Component, Input} from '@angular/core'
import {WorkflowDurations, WorkflowDuration} from '../../models/statistics/duration'
import {Workflow} from '../../models/workflow'
import {StatisticsService} from '../../services/statistics.service'

import * as moment from 'moment'

@Component({
  selector: 'duration-component',
  styleUrls: ['./duration.component.less'],
  templateUrl: 'duration.component.html'
})

export class DurationComponent {
  duration: WorkflowDuration = undefined

  @Input() workflow: Workflow
  @Input() display: string

  constructor(
    private statisticsService: StatisticsService,
  ) {}

  ngOnInit() {
    this.statisticsService.getWorkflowDurations(this.workflow.id)
    .subscribe(response => {
       if (response && response.data.length > 0) {
         this.duration = response.data[0];
       }
    });
  }


  public isFullMode() {
    return this.display == "full";
  }
}
