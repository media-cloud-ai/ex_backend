
import {Component, Input} from '@angular/core';
import {Workflow} from '../models/workflow';

@Component({
  selector: 'duration-component',
  templateUrl: 'duration.component.html',
})

export class DurationComponent {
  duration = undefined;

  @Input() workflow: Workflow;

  constructor(
  ) {}

  ngOnInit() {
    if(this.workflow.artifacts[0]) {
      var end = new Date(this.workflow.artifacts[0]["inserted_at"])
      var start = new Date(this.workflow.created_at)

      var duration : number = (+end - +start) / 1000;

      var seconds = Math.floor(duration % 60);
      var minutes = Math.floor(duration / 60);

      this.duration = {
        "minutes": minutes,
        "seconds": seconds
      }
    } else {
      this.duration = undefined;
    }
  }
}
