
import {Component, ViewChild} from '@angular/core';
import {PageEvent} from '@angular/material';
import {ActivatedRoute, Router} from '@angular/router';

import {JobService} from '../services/job.service';
import {JobPage} from '../services/job_page';
import {Job} from '../services/job';

import * as moment from 'moment';

@Component({
  selector: 'jobs-component',
  templateUrl: 'jobs.component.html',
  styleUrls: ['./jobs.component.less'],
})

export class JobsComponent {
  length = 1000;
  pageSize = 10;
  page = 0;
  sub = undefined;

  pageEvent: PageEvent;
  jobs: JobPage;

  constructor(
    private jobService: JobService,
    private route: ActivatedRoute,
    private router: Router
  ) {}

  ngOnInit() {
    this.sub = this.route
      .queryParams
      .subscribe(params => {
        this.page = +params['page'] || 0;
        this.getJobs(this.page);
      });
  }

  ngOnDestroy() {
    this.sub.unsubscribe();
  }

  getJobs(index): void {
    this.jobService.getJobs(index)
    .subscribe(jobPage => {
      this.jobs = jobPage;
      this.length = jobPage.total;
    });
  }

  eventGetJobs(event): void {
    this.router.navigate(['/jobs'], { queryParams: this.getQueryParamsForPage(event.pageIndex) });
    this.getJobs(event.pageIndex);
  }

  updateJobs(): void {
    this.router.navigate(['/jobs'], { queryParams: this.getQueryParamsForPage(0) });
    this.getJobs(0);
  }

  getQueryParamsForPage(pageIndex: number): Object {
    var params = {};
    if(pageIndex != 0) {
      params['page'] = pageIndex;
    }
    return params;
  }

}

