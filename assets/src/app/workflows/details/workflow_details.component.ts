import {Component} from '@angular/core';
import {ActivatedRoute, Router} from '@angular/router';

import {MatDialog} from '@angular/material';
import {Message} from '../../models/message';
import {SocketService} from '../../services/socket.service';
import {WorkflowService} from '../../services/workflow.service';
import {Workflow, Step} from '../../models/workflow';
import {WorkflowRenderer} from '../../models/workflow_renderer';
import {WorkflowAbortDialogComponent} from '../dialogs/workflow_abort_dialog.component';

@Component({
  selector: 'workflow-details-component',
  templateUrl: 'workflow_details.component.html',
  styleUrls: ['./workflow_details.component.less']
})
export class WorkflowDetailsComponent {
  private sub: any;

  workflow_id: number;
  workflow: Workflow;
  renderer: WorkflowRenderer;
  can_abort: boolean = false;
  connection: any;
  messages: Message[] = [];

  constructor(
    private socketService: SocketService,
    private workflowService: WorkflowService,
    private route: ActivatedRoute,
    private router: Router,
    public dialog: MatDialog
  ) {}

  ngOnInit() {
    this.sub = this.route
    .params.subscribe(params => {
      this.workflow_id = +params['id'];
      this.getWorkflow(this.workflow_id);
    });

    this.socketService.initSocket();

    this.connection = this.socketService.onWorkflowUpdate(this.workflow_id)
      .subscribe((message: Message) => {
        this.getWorkflow(this.workflow_id);
      });
  }

  ngOnDestroy() {
    this.sub.unsubscribe();
  }

  getWorkflow(workflow_id): void {
    this.workflowService.getWorkflow(workflow_id)
    .subscribe(workflow => {
      if(workflow == undefined) {
        this.workflow = undefined;
        this.renderer = undefined;
        return
      }

      this.workflow = workflow.data;
      this.renderer = new WorkflowRenderer(this.workflow.flow.steps);

      this.can_abort = this.workflow.flow.steps.some((s) => s.status == "error");
      if(this.can_abort && this.workflow.flow.steps.some((s) => s.name == "clean_workspace" && s.status != "queued")) {
        this.can_abort = false;
      }
    });
  }

  goToVideo(video_id): void {
    this.router.navigate(['/videos'], { queryParams: {video_id: video_id} });
  }

  getStepsCount(): string {
    let count = 0;
    for(let step of this.workflow.flow.steps) {
      if(step.jobs.skipped > 0 ||
         step.jobs.completed > 0 ||
         step.jobs.errors > 0) {
        count++;
      }
    }
    return count.toString();
  }

  getTotalSteps(): number {
    return this.workflow.flow.steps.length;
  }

  abort(workflow_id): void {
    let dialogRef = this.dialog.open(WorkflowAbortDialogComponent, {data: {"workflow": this.workflow}});

    dialogRef.afterClosed().subscribe(workflow => {
      if(workflow != undefined) {
        console.log("Abort workflow!");
        this.workflowService.sendWorkflowEvent(workflow.id, {event: "abort"})
        .subscribe(response => {
          console.log(response);
        });
      }
    });
  }
}
