
import {Component, ViewChild} from '@angular/core';
import {PageEvent} from '@angular/material';
import {ActivatedRoute, Router} from '@angular/router';

import {Message} from '../models/message';
import {SocketService} from '../services/socket.service';
import {WorkflowService} from '../services/workflow.service';
import {WorkflowPage} from '../models/page/workflow_page';
import {Workflow} from '../models/workflow';

import * as moment from 'moment';

@Component({
  selector: 'workflows-component',
  templateUrl: 'workflows.component.html',
  styleUrls: ['./workflows.component.less'],
})

export class WorkflowsComponent {
  length = 1000;
  pageSize = 10;
  video_id: string;
  page = 0;
  sub = undefined;

  pageEvent: PageEvent;
  workflows: WorkflowPage;
  connection: any;
  connections: any = [];
  messages: Message[] = [];

  constructor(
    private socketService: SocketService,
    private workflowService: WorkflowService,
    private route: ActivatedRoute,
    private router: Router
  ) {}

  ngOnInit() {
    this.sub = this.route
      .queryParams
      .subscribe(params => {
        this.page = +params['page'] || 0;
        this.video_id = params['video_id'];
        this.getWorkflows(this.page);

        this.socketService.initSocket();

        this.connection = this.socketService.onNewWorkflow()
          .subscribe((message: Message) => {
            this.getWorkflows(this.page);
          });
      });
  }

  ngOnDestroy() {
    if(this.sub) {
      this.sub.unsubscribe();
    }
  }

  getWorkflows(index): void {
    for(let connection of this.connections) {
      connection.unsubscribe();
    }

    this.workflowService.getWorkflows(index,
      this.video_id)
    .subscribe(workflowPage => {
      if(workflowPage == undefined) {
        this.length = undefined;
        this.workflows = new WorkflowPage();
        return;
      }

      this.workflows = workflowPage;
      this.length = workflowPage.total;

      for(let workflow of this.workflows.data) {
        var connection = this.socketService.onWorkflowUpdate(workflow.id)
          .subscribe((message: Message) => {
            this.updateWorkflow(message.body.workflow_id);
          });
      }
    });
  }

  eventGetWorkflows(event): void {
    this.router.navigate(['/workflows'], { queryParams: this.getQueryParamsForPage(event.pageIndex) });
    this.getWorkflows(event.pageIndex);
  }

  updateWorkflows(): void {
    this.router.navigate(['/workflows'], { queryParams: this.getQueryParamsForPage(0) });
    this.getWorkflows(0);
  }


  updateWorkflow(workflow_id): void {
    this.workflowService.getWorkflow(workflow_id)
    .subscribe(workflowData => {
      for (let i = 0; i < this.workflows.data.length; i++) {
        if(this.workflows.data[i].id == workflowData.data.id) {
          this.workflows.data[i] = workflowData.data;
          return
        }
      }
    });
  }

  getQueryParamsForPage(pageIndex: number): Object {
    var params = {};
    if(pageIndex != 0) {
      params['page'] = pageIndex;
    }
    
    if(this.video_id != "") {
      params['video_id'] = this.video_id;
    }
    return params;
  }
}
