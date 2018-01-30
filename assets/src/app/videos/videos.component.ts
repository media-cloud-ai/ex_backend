
import {Component, ViewChild} from '@angular/core';
import {PageEvent} from '@angular/material';
import {ActivatedRoute, Router} from '@angular/router';
import {FormControl} from '@angular/forms';

import {VideoService} from '../services/video.service';
import {VideoPage} from '../services/video_page';
import {Video} from '../services/video';
import {DateRange} from '../services/date_range';

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
  channels = [
    {id: "france-2", label: "France 2"},
    {id: "france-3", label: "France 3"},
    {id: "france-4", label: "France 4"},
    {id: "france-5", label: "France 5"},
    {id: "france-o", label: "France Ô"}
  ];
  selectedChannels = [];

  enableDatePickers = false;
  dateRange = new DateRange();

  pageEvent: PageEvent;
  videos: VideoPage;

  constructor(
    private videoService: VideoService,
    private route: ActivatedRoute,
    private router: Router
  ) {}

  ngOnInit() {
    this.sub = this.route
      .queryParams
      .subscribe(params => {
        this.page = +params['page'] || 0;
        this.selectedChannels = params['channels'] || this.getChannelIDsList();
        if(params['broadcasted_after'] && params['broadcasted_before']) {
          this.enableDatePickers = true;
          this.dateRange.setStartDate(moment(params['broadcasted_after']));
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
    this.videoService.getVideos(index, this.selectedChannels, (this.enableDatePickers? this.dateRange : undefined))
    .subscribe(videoPage => {
      this.videos = videoPage;
      this.length = videoPage.total;
    });
  }

  eventGetVideos(event): void {
    this.router.navigate(['/videos'], { queryParams: this.getQueryParamsForPage(event.pageIndex) });
    this.getVideos(event.pageIndex);
  }

  filterVideos(): void {
    this.router.navigate(['/videos'], { queryParams: this.getQueryParamsForPage(0) });
    this.getVideos(0);
  }

  getQueryParamsForPage(pageIndex: number): Object {
    var params = {
      page: pageIndex,
      channels: this.selectedChannels
    }
    if(this.enableDatePickers) {
      params["broadcasted_after"] = this.dateRange.getStart().format();
      params["broadcasted_before"] = this.dateRange.getEnd().format();
    }
    return params;
  }

  toggleDates(event): void {
    this.enableDatePickers = event.checked;
  }

  setStartDate(event): void {
    this.dateRange.setStartDate(event.value);
  }

  setEndDate(event): void {
    this.dateRange.setEndDate(event.value);
  }
}

