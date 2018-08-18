
import {Component, Input, OnChanges, SimpleChange} from '@angular/core'

import {Timecode} from 'ts-subtitle'

@Component({
  selector: 'timecode-component',
  templateUrl: 'timecode.component.html',
  styleUrls: ['./timecode.component.less'],
})

export class TimecodeComponent implements OnChanges {
  @Input() time: number
  @Input() framerate: number = 25.0

  hours: number
  minutes: number
  secondes: number
  frames: number

  constructor(
  ) {}

  ngOnInit() {
    this.update()
  }

  update() {
    var hours = Math.trunc(this.time / 3600)
    var minutes = Math.trunc((this.time / 60) - (hours * 60))
    var seconds = Math.trunc(this.time - minutes * 60 - (hours * 3600))
    var milli = Math.round(1000.0 * (this.time - seconds - (minutes * 60 ) - (hours * 3600)))
    var frames = milli * this.framerate / 1000.0
    this.hours = hours
    this.minutes = minutes
    this.secondes = seconds
    this.frames = frames
  }

  ngOnChanges(changes: {[propKey: string]: SimpleChange}) {
    if (changes && changes.time) {
      this.time = changes.time.currentValue
      this.update()
    }
  }
}
