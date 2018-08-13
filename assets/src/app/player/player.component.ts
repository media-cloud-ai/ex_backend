
import {Component} from '@angular/core';
import {MediaPlayer} from 'dashjs';

@Component({
  selector: 'player-component',
  templateUrl: 'player.component.html',
  styleUrls: ['./player.component.less'],
})

export class PlayerComponent {
  constructor(
  ) {}

  ngOnInit() {
    var videoPlayer = document.querySelector("#videoPlayer");
    var subtitleRenderingDiv = document.querySelector("#subtitle-rendering-div");
    var url = "/stream/manifest.mpd";

    // var url = "http://videos-pmd.francetv.fr/innovation/SubTil/6bcd5593-c73b-42e6-91d5-0a0f156ff08a/2018_08_02__18_51_44/manifest.mpd";
    // var url = "https://dash.akamaized.net/envivio/EnvivioDash3/manifest.mpd";
    var player = MediaPlayer().create();
    player.initialize(<HTMLElement>videoPlayer, url, false);
    player.attachTTMLRenderingDiv(<HTMLDivElement>subtitleRenderingDiv);

    // http://dash.edgesuite.net/akamai/test/caption_test/ElephantsDream/ElephantsDream_en.vtt
  }
}
