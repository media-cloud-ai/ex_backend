
import {Component, ViewChild} from '@angular/core'
import {MatCheckboxModule, PageEvent} from '@angular/material'
import {ActivatedRoute, Router} from '@angular/router'

import {WatcherService} from '../services/watcher.service'
import {WatcherPage} from '../models/page/watcher_page'

@Component({
  selector: 'watchers-component',
  templateUrl: 'watchers.component.html',
  styleUrls: ['./watchers.component.less'],
})

export class WatchersComponent {
  watchers: WatcherPage

  constructor(
    private watcherService: WatcherService,
    private route: ActivatedRoute,
    private router: Router
  ) {}

  ngOnInit() {
    this.getWatchers()
  }

  getWatchers(): void {
    this.watcherService.getWatchers()
    .subscribe(watcherPage => {
      this.watchers = watcherPage
    })
  }
}
