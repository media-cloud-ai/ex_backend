
import {Component, ViewChild} from '@angular/core';
import {PageEvent} from '@angular/material';
import {ActivatedRoute, Router} from '@angular/router';

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

  constructor(
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
      });
  }

  ngOnDestroy() {
    this.sub.unsubscribe();
  }

  getWorkflows(index): void {
    this.workflowService.getWorkflows(index,
      this.video_id)
    .subscribe(workflowPage => {
      this.workflows = workflowPage;
      this.length = workflowPage.total;
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

