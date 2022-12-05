import { Component, Input } from '@angular/core'
import { Subscription } from 'rxjs'

import { Message } from '../../models/message'
import { SocketService } from '../../services/socket.service'
import { StatisticsService } from '../../services/statistics.service'
import { WorkflowDuration } from '../../models/statistics/duration'
import { Workflow } from '../../models/workflow'

@Component({
  selector: 'duration-component',
  styleUrls: ['./duration.component.less'],
  templateUrl: 'duration.component.html',
})
export class DurationComponent {
  private readonly subscriptions = new Subscription()

  @Input() workflow: Workflow
  @Input() display: string

  duration: WorkflowDuration = undefined

  constructor(
    private socketService: SocketService,
    private statisticsService: StatisticsService,
  ) {}

  ngOnChanges() {
    this.getDurations()
  }

  ngOnInit() {
    if (this.isFullMode()) {
      this.socketService.initSocket()
      this.socketService.connectToChannel('notifications:all')

      this.subscriptions.add(
        this.socketService
          .onWorkflowUpdate(this.workflow.id)
          .subscribe((_message: Message) => {
            this.getDurations()
          }),
      )
    }
  }

  ngOnDestroy() {
    this.subscriptions.unsubscribe()
  }

  getDurations() {
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
