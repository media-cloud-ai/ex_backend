
import {Component, ViewChild} from '@angular/core';
import {MatDialog, PageEvent} from '@angular/material';
import {ActivatedRoute, Router} from '@angular/router';
import {FormControl} from '@angular/forms';

import {VideoService} from '../services/video.service';
import {WorkflowService} from '../services/workflow.service';
import {VideoPage} from '../models/page/video_page';
import {Video} from '../models/video';
import {DateRange} from '../models/date_range';

import {WorkflowDialogComponent} from './workflow/workflow_dialog.component';

import * as moment from 'moment';

@Component({
  selector: 'videos-component',
  templateUrl: 'videos.component.html',
  styleUrls: ['./videos.component.less'],
})

export class VideosComponent {
  length = 1000;
  pageSize = 10;
  page = 0;
  sub = undefined;

  searchInput = '';
  channels = [
    {id: 'france-2', label: 'France 2'},
    {id: 'france-3', label: 'France 3'},
    {id: 'france-4', label: 'France 4'},
    {id: 'france-5', label: 'France 5'},
    {id: 'france-o', label: 'France Ô'}
  ];
  selectedChannels = [];

  dateRange = new DateRange();

  pageEvent: PageEvent;
  videos: VideoPage;

  constructor(
    private videoService: VideoService,
    private workflowService: WorkflowService,
    private route: ActivatedRoute,
    private router: Router,
    public dialog: MatDialog
  ) {}

  ngOnInit() {
    this.sub = this.route
      .queryParams
      .subscribe(params => {
        this.page = +params['page'] || 0;
        var channels = params['channels'];
        if(channels && !Array.isArray(channels)){
          channels = [channels];
        }
        this.selectedChannels = channels || this.getChannelIDsList();
        this.searchInput = params['search'] || '';
        if(params['broadcasted_after']) {
          this.dateRange.setStartDate(moment(params['broadcasted_after']));
        }
        if(params['broadcasted_before']) {
          this.dateRange.setEndDate(moment(params['broadcasted_before']));
        }
        this.getVideos(this.page);
      });
  }

  ngOnDestroy() {
    this.sub.unsubscribe();
  }

  getChannelIDsList(): Array<string> {
    var channelIds = []
    this.channels.forEach(function(channel) {
      channelIds.push(channel.id);
    });
    return channelIds;
  }

  getVideos(index): void {
    this.videoService.getVideos(index,
      this.selectedChannels,
      this.searchInput,
      this.dateRange)
    .subscribe(videoPage => {
      this.videos = videoPage;
      this.length = videoPage.total;
    });
  }

  eventGetVideos(event): void {
    this.router.navigate(['/videos'], { queryParams: this.getQueryParamsForPage(event.pageIndex) });
    this.getVideos(event.pageIndex);
  }

  updateVideos(): void {
    this.router.navigate(['/videos'], { queryParams: this.getQueryParamsForPage(0) });
    this.getVideos(0);
  }

  getQueryParamsForPage(pageIndex: number): Object {
    var params = {
      "channels": this.selectedChannels
    }
    if(pageIndex != 0) {
      params['page'] = pageIndex;
    }

    if(this.searchInput != "") {
      params['search'] = this.searchInput;
    }

    if(this.dateRange.getStart() != undefined) {
      params['broadcasted_after'] = this.dateRange.getStart().format();
    }
    if(this.dateRange.getEnd() != undefined) {
      params['broadcasted_before'] = this.dateRange.getEnd().format();
    }
    return params;
  }

  setStartDate(event): void {
    this.dateRange.setStartDate(event.value);
    this.getQueryParamsForPage(0);
    this.updateVideos();
  }

  setEndDate(event): void {
    this.dateRange.setEndDate(event.value);
    this.getQueryParamsForPage(0);
    this.updateVideos();
  }

  updateStart(): void {
    this.getQueryParamsForPage(0);
    this.updateVideos();
  }

  updateEnd(): void {
    this.getQueryParamsForPage(0);
    this.updateVideos();
  }

  start_process(video): void {



    let dialogRef = this.dialog.open(WorkflowDialogComponent, {
      data: {
      }
    });

    dialogRef.afterClosed().subscribe(steps => {
      if(steps != undefined) {
        this.workflowService.createWorkflow({reference: video.id, flow: {steps: steps}})
        .subscribe(response => {
          console.log(response);
        });
      }
    });

    // this.videoService.ingest(video.legacy_id)
    // .subscribe(response => {
    //   // console.log(response);
    // });
  }

  redirect_to_workflow_view(video): void {
    this.router.navigate(['/workflows'], { queryParams: {video_id: video.id} });
  }

  get_encoded_uri(uri): string {
    return encodeURI("[\"" + uri + "\"]");
  }
}

