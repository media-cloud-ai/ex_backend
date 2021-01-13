
import {
  Component,
  EventEmitter,
  Input,
  OnChanges,
  Output,
  SimpleChange,
  HostListener
} from '@angular/core'
import {MatDialog} from '@angular/material/dialog'
import {HttpClient} from '@angular/common/http'
import {WebVtt, Cue, Timecode} from 'ts-subtitle'

import {MouseMoveService} from '../services/mousemove.service'
import {RegisteryService} from '../services/registery.service'

import {Subtitle} from '../models/registery'
import {SetVersionDialog} from './dialog/set_version_dialog'

@Component({
  selector: 'subtitle-component',
  templateUrl: 'subtitle.component.html',
  styleUrls: ['./subtitle.component.less'],
})

export class SubtitleComponent implements OnChanges {
  @Input() content_id: number
  @Input() subtitle: Subtitle
  @Input() time: number = 0.0
  @Input() before: number = 0
  @Input() after: number = 0
  @Input() split: boolean = false
  @Input() isChangingTimecode: boolean
  @Output() playSegment: EventEmitter<Cue> = new EventEmitter<Cue>();

  loaded = true
  canSave = false
  cues: Cue[] = []
  currentCue: Cue = new Cue()
  currentCueIndex: number
  beforeCues: Cue[] = []
  afterCues: Cue[] = []

  constructor(
    public dialog: MatDialog,
    private http: HttpClient,
    private mouseMoveService: MouseMoveService,
    private registeryService: RegisteryService,
  ) {}

  ngOnInit() {
    this.loadSubtitle(this.subtitle)
  }

  ngOnChanges(changes: {[propKey: string]: SimpleChange}) {
    if (changes && changes.time) {
      this.refresh(changes.time.currentValue)
    }
    if (changes && changes.subtitle) {
      this.loadSubtitle(changes.subtitle.currentValue)
    }
  }

  loadSubtitle(subtitle: Subtitle) {
    if(subtitle && subtitle.path) {
      this.loaded = false
      var subtitle_url = subtitle.path.replace("/dash", "/stream")
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

  refresh(currentTime) {
    var initialIndex = 0;

    for (var index = 0; index < this.cues.length; index++) {
      var cue = this.cues[index]
      if(cue && cue.start <= currentTime && cue.end >= currentTime) {
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
      if(cue && currentTime >= cue.end) {
        initialIndex += 1
      }
    }

    this.currentCue = null
    this.currentCueIndex = null
    this.beforeCues = [];
    this.afterCues = [];

    for(var beforeIndex = 1; beforeIndex <= this.before; beforeIndex++) {
      if(initialIndex - beforeIndex >= 0) {
        this.beforeCues.push(this.cues[initialIndex - beforeIndex])
      }
    }

    for(var afterIndex = 0; afterIndex < this.after; afterIndex++) {
      if(initialIndex + afterIndex < this.cues.length) {
        this.afterCues.push(this.cues[initialIndex + afterIndex])
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

    let dialogRef = this.dialog.open(SetVersionDialog, {data: this.time})
    dialogRef.afterClosed().subscribe(newVersion => {
      if(newVersion !== undefined) {
        this.registeryService.saveSubtitle(this.content_id, this.subtitle.index, content, newVersion)
        .subscribe(response => {
          this.canSave = false
        })
      }
    })
  }

  playCue(cue: Cue) {
    this.playSegment.next(cue)
  }

  focus() {
    this.mouseMoveService.focusSubtitleSource.next()
    this.canSave = true
  }

  focusOut() {
    this.mouseMoveService.outFocusSubtitleSource.next()
  }

  startTimeChange(event: number, cue: Cue) {
    if(cue) {
      cue.start = event
    }
  }

  endTimeChange(event: number, cue: Cue) {
    if(cue) {
      cue.end = event
    }
  }
}
