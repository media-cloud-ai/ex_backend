import { Component, Input, SimpleChanges } from '@angular/core'
import { Step } from '../../models/workflow'
import { WorkflowRenderer } from '../../models/workflow_renderer'

@Component({
  selector: 'workflow-renderer-component',
  templateUrl: 'workflow_renderer.component.html',
  styleUrls: ['./workflow_renderer.component.less'],
})
export class WorkflowRendererComponent {
  @Input() steps: Step[]

  renderer: WorkflowRenderer
  active_steps = {}

  constructor() {}

  ngOnInit() {
    this.loadSteps()
  }

  ngOnChanges(changes: SimpleChanges) {
    if (changes.steps) {
      this.loadSteps()
    }
  }

  loadSteps() {
    this.renderer = new WorkflowRenderer(this.steps)
  }
}
