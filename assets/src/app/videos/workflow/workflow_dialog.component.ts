import {Component, Inject} from '@angular/core';
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material';
import {Step} from '../../models/workflow';

@Component({
  selector: 'workflow_dialog',
  templateUrl: 'workflow_dialog.component.html',
  styleUrls: ['./workflow_dialog.component.less'],
})
export class WorkflowDialogComponent {

  acs_enable: boolean;
  steps: Step[];
  graph: Step[][];
  active_steps = {};

  constructor(public dialogRef: MatDialogRef<WorkflowDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any) {
    console.log("data:", data);
    this.acs_enable = data["broadcasted_live"];
    this.steps = [
      {
        id: 0,
        parent_ids: [],
        name: "download_ftp",
        enable: true,
        required: [],
        parameters: []
      },{
        id: 1,
        parent_ids: [0],
        name: "download_http",
        enable: true,
        required: [
          "download_ftp"
        ],
        parameters: []
      },{
        id: 2,
        parent_ids: [0],
        name: "audio_extraction",
        enable: true,
        required: [
          "download_ftp"
        ],
        parameters : []
      },{
        id: 3,
        parent_ids: [2],
        name: "audio_decode",
        enable: this.acs_enable,
        required: [
          "audio_extraction"
        ],
        parameters : []
      },{
        id: 4,
        parent_ids: [3],
        name: "acs_prepare_audio",
        enable: this.acs_enable,
        required: [
          "audio_decode"
        ],
        parameters : []
      },{
        id: 5,
        parent_ids: [4],
        name: "acs_synchronize",
        enable: this.acs_enable,
        required: [
          "acs_prepare_audio"
        ],
        parameters : []
      // },{
      //   id: "audio_encode",
      //   enable: this.acs_enable,
      //   parameters : []
      },{
        id: 6,
        parent_ids: [1, 5],
        name: "ttml_to_mp4",
        enable: true,
        required: [
          "download_http"
        ],
        parameters: []
      },{
        id: 7,
        parent_ids: [6],
        name: "set_language",
        enable: true,
        required: [
          "audio_extraction",
          "ttml_to_mp4"
        ],
        parameters : []
      },{
        id: 8,
        parent_ids: [7],
        name: "generate_dash",
        enable: true,
        required: [
          "set_language"
        ],
        parameters : [
          {
            id: "segment_duration",
            type: "number",
            default: 2000,
            value: 2000,
          },{
            id: "fragment_duration",
            type: "number",
            default: 2000,
            value: 2000,
          }
        ]
      },{
        id: 9,
        parent_ids: [8],
        name: "upload_ftp",
        enable: true,
        required: [
          "generate_dash"
        ],
        parameters: []
      },{
        id: 10,
        parent_ids: [9],
        name: "clean_workspace",
        required: [
          "download_ftp"
        ],
        enable: true,
        parameters: []
      }
    ]

    this.graph = new Array();
    this.initWorkflowGraph();

    this.updateStepRequirements(this.steps[0]);
  }

  private initWorkflowGraph(): void {

    for(let step of this.steps) {

      let child_line_index = 0;
      if(step.parent_ids.length != 0) {

        let parents_lines_index = this.graph
          .filter(line => line.filter(s => step.parent_ids.includes(s.id)).length > 0)
          .map(line => this.graph.indexOf(line));
        child_line_index = Math.max(...parents_lines_index) + 1;
      }

      if(this.graph[child_line_index] == undefined) {
        this.graph[child_line_index] = new Array<Step>();
      }
      this.graph[child_line_index].push(step);
    }

    for (var i = 1; i < this.graph.length; ++i) {
      let last_line = this.graph[i - 1];
      let cur_line = this.graph[i];

      let cur_line_length = cur_line.length;

      // we have to ensure each parent has an element under
      let last_line_ids = last_line.map(s => s.id);
      last_line_ids = last_line_ids.filter((s, pos) => last_line_ids.indexOf(s) == pos).sort((a, b) => a - b);

      let line_parent_ids = []
      for(let step of cur_line) {
        line_parent_ids = line_parent_ids.concat(step.parent_ids);
      }
      line_parent_ids = line_parent_ids.filter((s, pos) => line_parent_ids.indexOf(s) == pos).sort((a, b) => a - b);

      let ids_diff = last_line_ids.filter(id => line_parent_ids.indexOf(id) < 0)

      let no_child_parents = last_line.filter(s => ids_diff.includes(s.id));
      for(let parent of no_child_parents) {
        let idx = last_line.indexOf(parent);
        let fake_step = {
            id: parent.id,
            parent_ids: parent.parent_ids,
            name: undefined,
            enable: true,
            required: [],
            parameters: []
          };
          cur_line.splice(idx, 0, fake_step);
      }

      this.graph[i] = cur_line;
    }
  }

  getStepWeight(step: Step): number {
    let step_line: Step[] = this.graph.find(line => line.includes(step));
    let step_line_idx: number = this.graph.indexOf(step_line);

    if(step_line.length == 1) {
      return 1;
    }

    let children_weigth = 1;
    let children_line = this.graph[step_line_idx + 1];
    if(children_line != undefined) {
      let step_children = children_line.filter(s => s.parent_ids.includes(step.id));
      children_weigth = 1 / children_line.length;
      if(step_children.length > 0) {
        children_weigth = step_children.length / children_line.length;
      }
    }

    let parent_weigth = 1;
    let parent_line = this.graph[step_line_idx - 1];
    if(parent_line != undefined) {
      let step_parents = parent_line.filter(s => step.parent_ids.includes(s.id));
      parent_weigth = 1 / parent_line.length;
      if(step_parents.length > 0) {
        parent_weigth = step_parents.length / parent_line.length;
      }
    }

    return parent_weigth * children_weigth * step_line.length;
  }

  updateStepRequirements(step: Step) {
    let step_dependencies = this.steps.filter(s => step.required.some(dependency => dependency == s.name));
    let can_step_be_enabled = true;
    for(let dep of step_dependencies) {
      if(!dep.enable) {
        can_step_be_enabled = false;
      }
    }
    this.active_steps[step.name] = can_step_be_enabled;

    let step_children = this.steps.filter(s => s.parent_ids.includes(step.id)); // step.parent_ids.indexOf(s.id) >= 0
    for(let child of step_children) {
      this.updateStepRequirements(child);
    }
  }

  updateEnabledSteps(step: Step): void {
    if(!step.enable) {
      let step_children = this.steps.filter(s => s.parent_ids.includes(step.id)); // step.parent_ids.indexOf(s.id) >= 0
      for(let child of step_children) {
        child.enable = false;
        this.updateEnabledSteps(child);
      }
    }
    this.updateStepRequirements(step);
  }

  onNoClick(): void {
    this.dialogRef.close();
  }

  onClose(): void {
    var steps = [];
    for(let step of this.steps) {
      if(step.enable == true) {
        steps.push(step);
      }
    }
    this.dialogRef.close(steps);
  }
}
