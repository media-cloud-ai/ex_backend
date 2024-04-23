import { Component, Input } from '@angular/core'
import { WorkflowDuration } from '../../models/statistics/duration'

@Component({
  selector: 'duration-component',
  styleUrls: ['./duration.component.less'],
  templateUrl: 'duration.component.html',
})
export class DurationComponent {
  @Input() duration: WorkflowDuration
  @Input() display: string
}
