
import {Component, Input} from '@angular/core';
import {Router} from '@angular/router';

import {CatalogService} from '../services/catalog.service';
import {Catalog} from '../models/catalog';

@Component({
  selector: 'video-title-component',
  templateUrl: 'video_title.component.html',
  styleUrls: ['./video_title.component.less'],
})

export class VideoTitleComponent {
  @Input() id: string;

  video: Catalog;

  constructor(
    private router: Router,
    private catalogService: CatalogService,
  ) {}

  ngOnInit() {
    var index = 0;
    var page = 0;
    var selectedChannels = undefined;

    this.catalogService.getVideo(this.id)
    .subscribe(response => {
      console.log(response)
      this.video = response.data;
    });
  }

  gotoVideo(video_id): void {
    this.router.navigate(['/catalog'], { queryParams: {video_id: video_id} });
  }
}
