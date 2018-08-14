
import {Component, HostListener} from '@angular/core';
import {ActivatedRoute, Router} from '@angular/router';

import {
  MediaPlayer,
  PlaybackTimeUpdatedEvent,
  MediaPlayerEvents,
  } from 'dashjs';

import {Observable} from 'rxjs';
import 'rxjs/add/observable/interval';

@Component({
  selector: 'player-component',
  templateUrl: 'player.component.html',
  styleUrls: ['./player.component.less'],
})

export class PlayerComponent {
  player = MediaPlayer().create();
  time = 0;
  timecode = 0;
  content_id = null;
  previousISDState = null;
  tt = null;
  isd = null;

  sub = null;

  constructor(
    private route: ActivatedRoute,
  ) {}

  ngOnInit() {
    var videoPlayer = document.querySelector("#videoPlayer");

    this.sub = this.route
      .params.subscribe(params => {
        this.content_id = params['id'];

        var url = "/stream/" + this.content_id + "/manifest.mpd";

        this.player.getDebug().setLogToBrowserConsole(false);
        this.player.initialize(<HTMLElement>videoPlayer, url, false);

        this.player.on(MediaPlayer.events["PLAYBACK_PAUSED"], this.processEvent, this);
        this.player.on(MediaPlayer.events["PLAYBACK_ENDED"], this.processEvent, this);
        this.player.on(MediaPlayer.events["PLAYBACK_PLAYING"], this.processEvent, this);
      });

  }

  ngOnDestroy() {
    this.stopRefresh()
  }

  processEvent(event) {
    if(event.type == "playbackPlaying") {
      this.startRefresh();
    }
    if(event.type == "stopRefresh" || event.type == "playbackEnded") {
      this.startRefresh();
      this.getCurrentTime();
    }
  }

  startRefresh() {
    this.sub = Observable.interval(100)
    .subscribe((val) => {
      this.getCurrentTime();
    });
  }

  stopRefresh() {
    if(this.sub) {
      this.sub.unsubscribe();
    }
  }

  getCurrentTime() {
    if(this.player) {
      this.time = this.player.time();
      this.timecode = this.player.time() * 1000;
    }
  }

  @HostListener('window:keydown', ['$event'])
  keyDownEvent(event: KeyboardEvent) {
    if(event.ctrlKey == true && event.code == "Space") {
      return false;
    }
  }

  @HostListener('window:keyup', ['$event'])
  keyUpEvent(event: KeyboardEvent) {
    if(event.ctrlKey == true && event.code == "Space") {
      if(this.player.isPaused()) {
        this.player.play();
      } else {
        this.player.pause()
      }
      return false;
    }
  }
}
