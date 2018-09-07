
import {Component, Input} from '@angular/core'
import {Step} from '../../models/workflow'

@Component({
  selector: 'step-renderer',
  templateUrl: 'step_renderer.component.html',
  styleUrls: ['./step_renderer.component.less'],
})

export class StepRendererComponent {
  @Input() step: Step
  @Input() active: boolean
  open_parameters = false


  constructor() {}

  ngOnInit() {
  }
}
