
import {Component, ViewChild} from '@angular/core';
import {PageEvent} from '@angular/material';
import {ActivatedRoute, Router} from '@angular/router';
import {FormControl} from '@angular/forms';

import {VideoService} from '../services/video.service';
import {VideoPage} from '../services/video_page';
import {Video} from '../services/video';
import {DateRange} from '../services/date_range';

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
    // console.log(event);
    // console.log(this.page);
    this.router.navigate(['/videos'], { queryParams: { page: event.pageIndex } });
    this.getVideos(event.pageIndex);
  }

  filterVideos(selectedChannels): void {
    this.router.navigate(['/videos'], { queryParams: { page: 0, channels: selectedChannels } });
    this.getVideos(0);
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

