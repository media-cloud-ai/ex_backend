import { Component, Input } from '@angular/core'

import { Message } from '../../models/message'
import { SocketService } from '../../services/socket.service'
import { StatisticsService } from '../../services/statistics.service'
import { WorkflowDuration } from '../../models/statistics/duration'
import { Workflow } from '../../models/workflow'

import * as moment from 'moment'

@Component({
  selector: 'duration-component',
  styleUrls: ['./duration.component.less'],
  templateUrl: 'duration.component.html',
})
export class DurationComponent {
  connection: any

  @Input() workflow: Workflow
  @Input() display: string
  @Input() duration: WorkflowDuration = undefined

  constructor(
    private socketService: SocketService,
    private statisticsService: StatisticsService,
  ) {}

  ngOnInit() {
    if (this.duration == undefined) {
      this.getDurations(this.workflow.id)
    }

    if (this.isFullMode()) {
      this.socketService.initSocket()
      this.socketService.connectToChannel('notifications:all')

      this.connection = this.socketService
        .onWorkflowUpdate(this.workflow.id)
        .subscribe((message: Message) => {
          this.getDurations(this.workflow.id)
        })
    }
  }

  getDurations(workflow_id) {
    this.statisticsService
      .getWorkflowDurations(this.workflow.id)
      .subscribe((response) => {
        if (response && response.data.length > 0) {
          this.duration = response.data[0]
        }
      })
  }

  public isFullMode() {
    return this.display == 'full'
  }
}
