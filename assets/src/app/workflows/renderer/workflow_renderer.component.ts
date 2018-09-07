
import {Component, Input, SimpleChanges} from '@angular/core'
import {Step} from '../../models/workflow'
import {WorkflowRenderer} from '../../models/workflow_renderer'

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
    if(changes.steps) {
      this.loadSteps()
    }
  }

  loadSteps() {
    this.renderer = new WorkflowRenderer(this.steps)
    if(this.steps && this.steps.length > 0) {
      this.updateStepRequirements(this.steps[0])
    }
  }

  updateStepRequirements(step: Step) {
    let step_dependencies = this.steps.filter(s => step.required && step.required.some(dependency => dependency === s.name))
    let can_step_be_enabled = true
    for (let dependency of step_dependencies) {
      if (!dependency.enable) {
        can_step_be_enabled = false
      }
    }
    this.active_steps[step.name] = can_step_be_enabled
    if (!can_step_be_enabled) {
      step.enable = false
    }

    let step_children = this.steps.filter(s => s.parent_ids && s.parent_ids.includes(step.id))
    for (let child of step_children) {
      this.updateStepRequirements(child)
    }
  }

  // updateEnabledSteps(step: Step): void {
  //   if (!step.enable) {
  //     let step_children = this.steps.filter(s => s.parent_ids && s.parent_ids.includes(step.id))
  //     for (let child of step_children) {
  //       if (child.enable && child.parent_ids.length > 1) {
  //         // handle multiple parents case
  //         let has_enabled_parents = this.steps.some(s => child.parent_ids.includes(s.id) && s.enable)
  //         if (has_enabled_parents) {
  //           continue
  //         }
  //       }

  //       child.enable = false
  //       this.updateEnabledSteps(child)
  //     }
  //   }
  //   this.updateStepRequirements(step)
  // }
}
