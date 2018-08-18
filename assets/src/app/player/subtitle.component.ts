
import {Component, Input, OnChanges, SimpleChange} from '@angular/core'
import {HttpClient} from '@angular/common/http'
import {WebVtt, Cue, Timecode} from 'ts-subtitle'

@Component({
  selector: 'subtitle-component',
  templateUrl: 'subtitle.component.html',
  styleUrls: ['./subtitle.component.less'],
})

export class SubtitleComponent implements OnChanges {
  @Input() content_id: string
  @Input() language: string
  @Input() time: number

  webvtt = new WebVtt()
  loaded = false
  cues: Cue[] = []
  currentCue: Cue

  constructor(
    private http: HttpClient,
  ) {}

  ngOnInit() {
    // var subtitle_url = '/stream/' + this.content_id + '/' + this.language + '.ttml'
    var subtitle_url = '/stream/' + this.content_id + '/' + this.language + '.vtt'
    this.http.get(subtitle_url, {responseType: 'text'})
    .subscribe(contents => {
      if(this.webvtt.parse(contents)) {
        this.loaded = true
        this.cues = this.webvtt.get_cues()
      }
      this.refresh(0)
    })
  }

  ngOnChanges(changes: {[propKey: string]: SimpleChange}) {
    if (changes && changes.time) {
      this.refresh(changes.time.currentValue)
    }
  }

  refresh(time) {
    for(var cue of this.cues) {
      if(cue.start <= time && cue.end >= time) {
        this.currentCue = cue
        return
      }
    }
    this.currentCue = null
  }
}
