import { Component, Input } from '@angular/core'
import { Step } from '../../models/workflow'

@Component({
  selector: 'step-renderer',
  templateUrl: 'step_renderer.component.html',
  styleUrls: ['./step_renderer.component.less'],
})
export class StepRendererComponent {
  @Input() step: Step
  open_parameters = false

  constructor() {
    // do nothing
  }

  ngOnInit() {
    // do nothing
  }
}
