
import {
  Component,
  Input,
  OnChanges,
  SimpleChange,
  HostListener
} from '@angular/core'
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
  @Input() time: number = 0
  @Input() before: number = 0
  @Input() after: number = 0

  loaded = false
  cues: Cue[] = []
  currentCue: Cue
  beforeCues: Cue[] = []
  afterCues: Cue[] = []

  constructor(
    private http: HttpClient,
  ) {}

  ngOnInit() {
    this.loadSubtitle(this.language)
  }

  ngOnChanges(changes: {[propKey: string]: SimpleChange}) {
    // console.log(changes)
    if (changes && changes.time) {
      this.refresh(changes.time.currentValue)
    }
    if (changes && changes.language) {
      this.loadSubtitle(changes.language.currentValue)
    }
  }

  loadSubtitle(language) {
    this.loaded = false
    var subtitle_url = '/stream/' + this.content_id + '/' + language + '.vtt'
    this.http.get(subtitle_url, {responseType: 'text'})
    .subscribe(contents => {
      var webvtt = new WebVtt()
      if(webvtt.parse(contents)) {
        this.loaded = true
        this.cues = webvtt.get_cues()
        this.refresh(this.time)
      }
    })
  }

  refresh(time) {
    for (var index = 0; index < this.cues.length; index++) {
      var cue = this.cues[index]
      if(cue.start <= time && cue.end >= time) {
        // console.log(cue);
        this.currentCue = cue

        this.beforeCues = [];
        for(var beforeIndex = 1; beforeIndex <= this.before; beforeIndex++) {
          if(index - beforeIndex >= 0) {
            this.beforeCues.push(this.cues[index - beforeIndex])
          }
        }

        this.afterCues = [];
        for(var afterIndex = 1; afterIndex <= this.after; afterIndex++) {
          if(index + afterIndex < this.cues.length) {
            this.afterCues.push(this.cues[index + afterIndex])
          }
        }

        return
      }
    }
    this.currentCue = null
    this.beforeCues = [];
    this.afterCues = [];
    for(var afterIndex = 1; afterIndex <= this.after; afterIndex++) {
      if(afterIndex < this.cues.length) {
        this.afterCues.push(this.cues[afterIndex])
      }
    }
  }

  cutSubtitle() {
    console.log("cut !");
    var selection = window.getSelection();
    console.log("selection ", selection);
    var index = 0;
    console.log(selection.getRangeAt(index))
    console.log(selection.getRangeAt(index).collapsed)
    console.log(selection.getRangeAt(index).startOffset)
    console.log(selection.getRangeAt(index).endOffset)
    console.log(selection.getRangeAt(index).startContainer )
    console.log(selection.getRangeAt(index).endContainer )
  }

  @HostListener('window:keydown', ['$event'])
  keyDownEvent(event: KeyboardEvent) {
    if (event.ctrlKey === true && event.code === 'KeyC') {
      return false
    }
  }

  @HostListener('window:keyup', ['$event'])
  keyUpEvent(event: KeyboardEvent) {
    if (event.ctrlKey === true && event.code === 'KeyC') {
      this.cutSubtitle()
      return false
    }
  }
}
