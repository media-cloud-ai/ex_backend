
import {Component, Input} from '@angular/core'
import {ActivatedRoute, Router} from '@angular/router'

import {Registery} from '../models/registery'
import {
  MediaPlayer,
  PlaybackTimeUpdatedEvent,
  MediaPlayerEvents,
  } from 'dashjs'

@Component({
  selector: 'registery-component',
  templateUrl: 'registery.component.html',
  styleUrls: ['./registery.component.less'],
})

export class RegisteryComponent {
  @Input() item: Registery
  @Input() index: number
  player = MediaPlayer().create()

  playing = false
  htmlPlayer = ""

  constructor(
    private router: Router
  ) {}

  ngOnInit() {
    var videoPlayer = document.querySelectorAll(".videoPlayer")[this.index]

    if(this.item.params.manifests &&
      this.item.params.manifests.length > 0 &&
      this.item.params.manifests[0].paths &&
      this.item.params.manifests[0].paths.length > 0) {
      var url = this.item.params.manifests[0].paths[0].replace("/dash", "/stream")

      this.player.getDebug().setLogToBrowserConsole(false)
      this.player.initialize(<HTMLElement>videoPlayer, url, false)
    }
  }

  play() {
    if(this.playing) {
      this.player.pause()
      this.playing = false
    } else {
      this.player.play()
      this.playing = true
    }
  }

  openPlayer() {
    this.router.navigate(['/player/' + this.item.workflow_id])
  }
}
