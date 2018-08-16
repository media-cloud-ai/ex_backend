
import {Component, Input} from '@angular/core'
import {Router} from '@angular/router'

import {ApplicationService} from '../services/application.service'
import {CatalogService} from '../services/catalog.service'
import {Application} from '../models/application'
import {Catalog} from '../models/catalog'

@Component({
  selector: 'video-title-component',
  templateUrl: 'video_title.component.html',
  styleUrls: ['./video_title.component.less'],
})

export class VideoTitleComponent {
  @Input() id: string

  application: Application
  video: Catalog

  constructor(
    private applicationService: ApplicationService,
    private router: Router,
    private catalogService: CatalogService,
  ) {}

  ngOnInit() {
    var index = 0
    var page = 0
    var selectedChannels = undefined

    this.applicationService.get_cached_app()
    .subscribe(response => {
      this.application = response

      if (this.application.identifier === 'subtil') {
        this.catalogService.getVideo(this.id)
        .subscribe(response => {
          this.video = response.data
        })
      }
    })
  }

  gotoVideo(video_id): void {
    this.router.navigate(['/catalog'], { queryParams: {video_id: video_id} })
  }
}
