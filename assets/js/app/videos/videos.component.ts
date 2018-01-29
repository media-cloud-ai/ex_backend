
import {Component, ViewChild} from '@angular/core';
import {PageEvent} from '@angular/material';
import {ActivatedRoute, Router} from '@angular/router';

import {VideoService} from '../services/video.service';
import {VideoPage} from '../services/video_page';
import {Video} from '../services/video';

@Component({
  selector: 'videos-component',
  templateUrl: 'videos.component.html',
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
        this.getVideos(this.page);
      });
  }

  ngOnDestroy() {
    this.sub.unsubscribe();
  }

  getVideos(index): void {
    this.videoService.getVideos(index)
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
}

