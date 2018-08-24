
import {Component, HostListener} from '@angular/core'
import {ActivatedRoute, Router} from '@angular/router'

import {
  MediaPlayer,
  PlaybackTimeUpdatedEvent,
  MediaPlayerEvents,
  } from 'dashjs'

import {Observable} from 'rxjs'
import 'rxjs/add/observable/interval'

@Component({
  selector: 'player-component',
  templateUrl: 'player.component.html',
  styleUrls: ['./player.component.less'],
})

export class PlayerComponent {
  player = MediaPlayer().create()
  duration = 0
  time = 0
  timecode = 0
  content_id = null
  previousISDState = null
  tt = null
  isd = null

  sub = null
  playing = false
  showHelp = false

  leftLanguage = "english"
  rightLanguage = "french"
  languages = [
    "english",
    "french",
  ]

  constructor(
    private route: ActivatedRoute,
  ) {}

  ngOnInit() {
    var videoPlayer = document.querySelector('#videoPlayer')

    this.sub = this.route
      .params.subscribe(params => {
        this.content_id = params['id']

        var url = '/stream/' + this.content_id + '/manifest.mpd'

        this.player.getDebug().setLogToBrowserConsole(false)
        this.player.initialize(<HTMLElement>videoPlayer, url, false)

        this.player.on(MediaPlayer.events['PLAYBACK_PAUSED'], this.processEvent, this)
        this.player.on(MediaPlayer.events['PLAYBACK_ENDED'], this.processEvent, this)
        this.player.on(MediaPlayer.events['PLAYBACK_PLAYING'], this.processEvent, this)
        this.player.on(MediaPlayer.events['PLAYBACK_METADATA_LOADED'], this.processEvent, this)
      })

  }

  ngOnDestroy() {
    this.stopRefresh()
  }

  switchHelp() {
    this.showHelp = !this.showHelp
  }

  processEvent(event) {
    // console.log(event)
    if (event.type === 'playbackMetaDataLoaded') {
      this.duration = this.player.duration()
    }
    if (event.type === 'playbackPlaying') {
      this.startRefresh()
    }
    if (event.type === 'stopRefresh' || event.type === 'playbackEnded') {
      this.startRefresh()
      this.getCurrentTime()
      this.playing = false
    }
  }

  startRefresh() {
    this.sub = Observable.interval(100)
    .subscribe((val) => {
      this.getCurrentTime()
    })
  }

  stopRefresh() {
    if (this.sub) {
      this.sub.unsubscribe()
    }
  }

  getCurrentTime() {
    if (this.player) {
      this.time = this.player.time()
      this.timecode = this.player.time() * 1000
    }
  }

  playPauseSwitch() {
    this.playing = !this.playing
    if(this.playing) {
      this.player.play()
    } else {
      this.player.pause()
    }
  }

  replay(duration: number) {
    if(this.playing) {
      this.player.pause()
    }
    this.player.seek(duration)
    this.player.preload()
    this.player.play()
    this.playing = true
  }

  back2seconds() {
    this.replay(this.player.time() - 2)
  }

  onSliderChange(event) {
    this.replay(event.value)
  }

  @HostListener('window:keydown', ['$event'])
  keyDownEvent(event: KeyboardEvent) {
    if (event.ctrlKey === true && event.code === 'Space') {
      return false
    }
  }

  @HostListener('window:keyup', ['$event'])
  keyUpEvent(event: KeyboardEvent) {
    // console.log(event)
    if (event.ctrlKey === true && event.code === 'Space') {
      this.playPauseSwitch()
      return false
    }
    if (event.ctrlKey === true && event.code === 'KeyR') {
      this.back2seconds()
      return false
    }
    if (event.ctrlKey === true && event.code === 'KeyS') {
      this.replay(0)
      return false
    }
    if (event.ctrlKey === true && event.code === 'KeyE') {
      this.replay(this.player.duration() - 0.1)
      return false
    }
    if (event.ctrlKey === true && event.code === 'KeyH') {
      this.showHelp = !this.showHelp
      return false
    }
  }
}
