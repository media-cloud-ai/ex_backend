import { Workflow, Step } from './workflow'

export class WorkflowRenderer {
  workflow: Workflow
  graph: Step[][]

  constructor(steps: Step[]) {
    this.graph = []

    if (steps === undefined) {
      return
    }
    for (const step of steps) {
      let child_line_index = 0
      if (step.parent_ids && step.parent_ids.length !== 0) {
        const parents_lines_index = this.graph
          .filter(
            (line) =>
              line.filter((s) => step.parent_ids.includes(s.id)).length > 0,
          )
          .map((line) => this.graph.indexOf(line))
        child_line_index = Math.max(...parents_lines_index) + 1
      }

      if (this.graph[child_line_index] === undefined) {
        this.graph[child_line_index] = new Array<Step>()
      }
      this.graph[child_line_index].push(step)
    }

    if (this.graph === undefined) {
      return
    }

    for (let i = 1; i < this.graph.length; ++i) {
      const last_line = this.graph[i - 1]
      const current_line = this.graph[i]

      // we have to ensure each parent has an element under
      let last_line_ids = last_line.map((s) => s.id)
      last_line_ids = last_line_ids
        .filter((s, pos) => last_line_ids.indexOf(s) === pos)
        .sort((a, b) => a - b)

      let line_parent_ids = []
      for (const step of current_line) {
        line_parent_ids = line_parent_ids.concat(step.parent_ids)
      }
      line_parent_ids = line_parent_ids
        .filter((s, pos) => line_parent_ids.indexOf(s) === pos)
        .sort((a, b) => a - b)

      const ids_diff = last_line_ids.filter((id) => !line_parent_ids.includes(id))

      const no_child_parents = last_line.filter((s) => ids_diff.includes(s.id))
      for (const parent of no_child_parents) {
        const idx = last_line.indexOf(parent)
        const fake_step = {
          id: parent.id,
          parent_ids: parent.parent_ids,
          name: undefined,
          enable: true,
        }

        current_line.splice(idx, 0, fake_step)
      }

      this.graph[i] = current_line
    }
    // console.log(this.graph)
  }

  getStepWeight(step: Step): number {
    const step_line: Step[] = this.graph.find((line) => line.includes(step))
    const step_line_idx: number = this.graph.indexOf(step_line)

    if (step_line.length === 1) {
      return 1
    }

    let children_weigth = 1
    const children_line = this.graph[step_line_idx + 1]
    if (children_line !== undefined) {
      const step_children = children_line.filter(
        (s) => s.parent_ids && s.parent_ids.includes(step.id),
      )
      children_weigth = 1 / children_line.length
      if (step_children.length > 0) {
        children_weigth = step_children.length / children_line.length
      }
    }

    let parent_weigth = 1
    const parent_line = this.graph[step_line_idx - 1]
    if (parent_line !== undefined) {
      const parent_ids = step.parent_ids || []

      const step_parents = parent_line.filter(
        (s) => s.parent_ids && parent_ids.includes(s.id),
      )
      parent_weigth = 1 / parent_line.length
      if (step_parents.length > 0) {
        parent_weigth = step_parents.length / parent_line.length
      }
    }

    return parent_weigth * children_weigth * step_line.length
  }

  public setStepFocus(step_focus: Map<number, boolean>) {
    for (const steps_line of this.graph) {
      for (const step of steps_line) {
        step.focus = step_focus.get(step.id) || false
      }
    }
  }
}
