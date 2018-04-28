import {Component} from '@angular/core';
import {ActivatedRoute, Router} from '@angular/router';

import {WorkflowService} from '../../services/workflow.service';
import {Workflow, Step} from '../../models/workflow';
import {WorkflowRender} from '../../models/workflow_render';

@Component({
  selector: 'workflow-details-component',
  templateUrl: 'workflow_details.component.html',
  styleUrls: ['./workflow_details.component.less']
})
export class WorkflowDetailsComponent {
  private sub: any;

  workflow: Workflow;
  render: WorkflowRender;

  constructor(
    private workflowService: WorkflowService,
    private route: ActivatedRoute,
    private router: Router
  ) {}

  ngOnInit() {
    this.sub = this.route
    .params.subscribe(params => {
      let workflow_id = +params['id'];
      this.getWorkflow(workflow_id);
    });
  }

  ngOnDestroy() {
    this.sub.unsubscribe();
  }

  getWorkflow(workflow_id): void {
    this.workflowService.getWorkflow(workflow_id)
    .subscribe(workflow => {
      this.workflow = workflow["data"];
      this.render = new WorkflowRender(this.workflow.flow.steps);
    });
  }

  goToVideo(video_id): void {
    this.router.navigate(['/videos'], { queryParams: {video_id: video_id} });
  }

  getStepsCount(): string {
    let count = 0;
    for(let step of this.workflow["flow"].steps) {
      if(step["jobs"].skipped > 0 ||
         step["jobs"].completed > 0 ||
         step["jobs"].errors > 0) {
        count++;
      }
    }
    return count.toString();
  }

  getTotalSteps(): number {
    return this.workflow["flow"].steps.length;
  }
}
