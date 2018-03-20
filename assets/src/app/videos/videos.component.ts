
import {Component, ViewChild} from '@angular/core';
import {MatDialog, MatCheckboxModule, PageEvent} from '@angular/material';
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
  pageSizeOptions = [
    10,
    20,
    50,
    100
  ];
  page = 0;
  sub = undefined;
  loading = true;

  searchInput = '';
  videoid = '';
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

  selectedVideos = [];

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
        this.pageSize = +params['per_page'] || 10;
        var channels = params['channels'];
        if(channels && !Array.isArray(channels)){
          channels = [channels];
        }
        this.selectedChannels = channels || this.getChannelIDsList();
        this.searchInput = params['search'] || '';
        if(params['broadcasted_after']) {
          this.dateRange.setStartDate(moment(params['broadcasted_after'], "YYYY-MM-DD"));
        }
        if(params['broadcasted_before']) {
          this.dateRange.setEndDate(moment(params['broadcasted_before'], "YYYY-MM-DD"));
        }
        if(params['video_id'] && params['video_id'].length == 36) {
          this.videoid = params['video_id'];
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
    this.loading = true;
    this.videoService.getVideos(index,
      this.pageSize,
      this.selectedChannels,
      this.searchInput,
      this.dateRange,
      this.videoid)
    .subscribe(videoPage => {
      this.videos = videoPage;
      this.length = videoPage.total;
      this.loading = false;
    });
  }

  eventGetVideos(event): void {
    this.router.navigate(['/videos'], { queryParams: this.getQueryParamsForPage(event.pageIndex, event.pageSize) });
  }

  updateVideos(): void {
    this.router.navigate(['/videos'], { queryParams: this.getQueryParamsForPage(0) });
    this.getVideos(0);
  }

  updateSearchByVideoId(): void {
    if(this.videoid.length == 36) {
      this.getVideos(0);
    }
  }

  getQueryParamsForPage(pageIndex: number, pageSize: number = undefined): Object {
    var params = {}

    if(this.selectedChannels.length != this.channels.length) {
      params['channels'] = this.selectedChannels;
    }
    if(pageIndex != 0) {
      params['page'] = pageIndex;
    }
    if(this.searchInput != "") {
      params['search'] = this.searchInput;
    }
    if(this.dateRange.getStart() != undefined) {
      params['broadcasted_after'] = this.dateRange.getStart().format('YYYY-MM-DD');
    }
    if(this.dateRange.getEnd() != undefined) {
      params['broadcasted_before'] = this.dateRange.getEnd().format('YYYY-MM-DD');
    }
    if(this.videoid && this.videoid.length == 36) {
      params['video_id'] = this.videoid;
    }
    if(pageSize) {
      if(pageSize != 10) {
        params['per_page'] = pageSize;
      }
    } else {
      if(this.pageSize != 10) {
        params['per_page'] = this.pageSize;
      }
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

  selectVideo(video, checked): void {
    video.selected = checked;
    if(checked) {
      this.selectedVideos.push(video);
    } else {
      this.selectedVideos = this.selectedVideos.filter(v => v.id !== video.id);
    }
  }

  selectAllVideos(event): void {
    for(let video of this.videos.data) {
      if(video.available) {
        this.selectVideo(video, event.checked);
      }
    }
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
  }

  start_all_process(): void {
    let dialogRef = this.dialog.open(WorkflowDialogComponent, {
      data: {
      }
    });

    dialogRef.afterClosed().subscribe(steps => {
      if(steps != undefined) {
        for(let video of this.selectedVideos) {
          this.workflowService.createWorkflow({reference: video.id, flow: {steps: steps}})
          .subscribe(response => {
            console.log(response);
          });
        }
      }
    });
  }

  get_encoded_uri(uri): string {
    return encodeURI("[\"" + uri + "\"]");
  }
}

