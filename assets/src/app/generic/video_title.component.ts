import { Component, Input } from '@angular/core'
import { Router } from '@angular/router'

import { ApplicationService } from '../services/application.service'
import { Application } from '../models/application'

@Component({
  selector: 'video-title-component',
  templateUrl: 'video_title.component.html',
  styleUrls: ['./video_title.component.less'],
})
export class VideoTitleComponent {
  @Input() id: string

  application: Application
  loading = true

  constructor(
    private applicationService: ApplicationService,
    private router: Router,
  ) {}

  ngOnInit() {
    const _index = 0
    const _page = 0
    const _selectedChannels = undefined
    this.loading = true

    this.applicationService.get_cached_app().subscribe((response) => {
      this.application = response
    })
  }
}
