
import {Component, Input} from '@angular/core';
import {Router} from '@angular/router';

import {VideoService} from '../services/video.service';
import {Video} from '../models/video';

@Component({
  selector: 'video-title-component',
  templateUrl: 'video_title.component.html',
  styleUrls: ['./video_title.component.less'],
})

export class VideoTitleComponent {
  @Input() id: string;

  video: Video;

  constructor(
    private router: Router,
    private videoService: VideoService,
  ) {}

  ngOnInit() {
    var index = 0;
    var page = 0;
    var selectedChannels = undefined;

    this.videoService.getVideo(this.id)
    .subscribe(response => {
      console.log(response)
      this.video = response.data;
    });
  }

  gotoVideo(video_id): void {
    this.router.navigate(['/videos'], { queryParams: {video_id: video_id} });
  }
}
