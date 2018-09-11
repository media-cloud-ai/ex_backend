
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
  @Input() language: any
  @Input() time: number = 0.0
  @Input() before: number = 0
  @Input() after: number = 0
  @Input() split: boolean = false
  @Input() isChangingTimecode: boolean

  loaded = true
  cues: Cue[] = []
  currentCue: Cue = new Cue()
  currentCueIndex: number
  beforeCues: Cue[] = []
  afterCues: Cue[] = []

  constructor(
    private http: HttpClient,
  ) {}

  ngOnInit() {
    this.loadSubtitle(this.language)
  }

  ngOnChanges(changes: {[propKey: string]: SimpleChange}) {
    if (changes && changes.time) {
      this.refresh(changes.time.currentValue)
    }
    if (changes && changes.language) {
      this.loadSubtitle(changes.language.currentValue)
    }
  }

  loadSubtitle(language) {
    if(language && language.paths) {
      this.loaded = false
      var subtitle_url = language.paths[0].replace("/dash", "/stream")
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
  }

  refresh(time) {
    for (var index = 0; index < this.cues.length; index++) {
      var cue = this.cues[index]
      if(cue.start <= time && cue.end >= time) {
        // console.log(cue);
        this.currentCue = cue
        this.currentCueIndex = index

        this.beforeCues = []
        for(var beforeIndex = 1; beforeIndex <= this.before; beforeIndex++) {
          if(index - beforeIndex >= 0) {
            this.beforeCues.push(this.cues[index - beforeIndex])
          }
        }

        this.afterCues = []
        for(var afterIndex = 1; afterIndex <= this.after; afterIndex++) {
          if(index + afterIndex < this.cues.length) {
            this.afterCues.push(this.cues[index + afterIndex])
          }
        }

        return
      }
    }
    this.currentCue = null
    this.currentCueIndex = null
    this.beforeCues = [];
    this.afterCues = [];
    for(var afterIndex = 1; afterIndex <= this.after; afterIndex++) {
      if(afterIndex < this.cues.length) {
        this.afterCues.push(this.cues[afterIndex])
      }
    }
  }

  merge(cue: Cue) {
    var index = this.currentCueIndex + 1
    cue.content = cue.content + this.cues[index].content
    cue.end = this.cues[index].end

    this.cues.splice(index, 1)
    this.refresh(this.time)
  }

  cutSubtitle(event) {
    if(this.currentCue && this.split && (event.toElement.selectionStart == event.toElement.selectionEnd)) {
      let before = this.currentCue.content.substring(0, event.toElement.selectionStart);
      let after = this.currentCue.content.substring(event.toElement.selectionStart);

      var next = new Cue()
      next.start = this.time
      next.end = this.currentCue.end
      next.content = after

      this.currentCue.end = this.time
      this.currentCue.content = before
      this.cues.splice(this.currentCueIndex + 1, 0, next);
      this.refresh(this.time)
    }
  }

  addCue() {
    if(this.currentCue && this.currentCue.end) {
      var next = new Cue()
      next.start = this.currentCue.end
      next.end = this.currentCue.end + 1.0
      next.content = ""
      this.cues.splice(this.currentCueIndex + 1, 0, next);
      this.refresh(this.time)
    } else {
      var next = new Cue()
      next.start = this.time
      next.end = this.time + 1.0
      next.content = ""
      this.cues.splice(0, 0, next);
      this.refresh(this.time)
    }
  }

  save() {
    var webvtt = new WebVtt()
    webvtt.set_cues(this.cues)
    var content = webvtt.dump()
    console.log(content)
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
      // this.cutSubtitle()
      return false
    }
  }
}
