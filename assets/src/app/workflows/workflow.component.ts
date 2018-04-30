
import {Component, Input} from '@angular/core';
import {Router} from '@angular/router';
import {Workflow, Step} from '../models/workflow';

@Component({
  selector: 'workflow-component',
  templateUrl: 'workflow.component.html',
  styleUrls: ['./workflow.component.less'],
})

export class WorkflowComponent {
  jobs_opened: boolean = false;
  @Input() workflow: Workflow;
  processing_steps: Step[] = new Array();
  error_steps: Step[] = new Array();

  constructor(
    private router: Router,
  ) {}

  ngOnInit() {
    for(let step of this.workflow.flow.steps){
      // console.log(step);
      if(step.jobs.errors > 0) {
        this.error_steps.push(step);
      }
      if(step.jobs.queued > 0) {
        this.processing_steps.push(step);
      }
    }
  }

  openJobs() : void {
    this.jobs_opened = true;
  }
  closeJobs() : void {
    this.jobs_opened = false;
  }

  gotoVideo(video_id): void {
    this.router.navigate(['/videos'], { queryParams: {video_id: video_id} });
  }

  goToDetails(workflow_id): void {
    this.router.navigate(['/workflows', workflow_id]);
  }

  getStepsCount(): number {
    let count = 0;
    for(let step of this.workflow.flow.steps) {
      if(step.jobs.skipped > 0 ||
         step.jobs.completed > 0 ||
         step.jobs.errors > 0) {
        count++;
      }
    }
    return count;
  }
  
  getTotalSteps(): number {
    return this.workflow["flow"].steps.length;
  }
}
