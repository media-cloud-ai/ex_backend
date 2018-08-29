
import {Component, HostListener, Input, OnChanges, SimpleChange} from '@angular/core'
import {MatDialog} from '@angular/material'

import {Timecode} from 'ts-subtitle'
import {Subscription} from 'rxjs'

import {MouseMoveService} from '../services/mousemove.service'
import {TimecodeDialogComponent} from './dialog/timecode_dialog.component'

@Component({
  selector: 'timecode-component',
  templateUrl: 'timecode.component.html',
  styleUrls: ['./timecode.component.less'],
})

export class TimecodeComponent implements OnChanges {
  @Input() time: number
  @Input() framerate: number = 25.0
  @Input() isChangingTimecode: boolean

  private originalTime: number

  private hours: number
  private minutes: number
  private secondes: number
  private frames: number

  private clicked: boolean = false;
  private origin: number;
  private last: MouseEvent;

  private sub: Subscription

  constructor(
    private mouseMoveService: MouseMoveService,
    public dialog: MatDialog,
  ) {}

  ngOnInit() {
    this.update()
    var me = this;

    this.sub = this.mouseMoveService.mouseMoveEvent.subscribe(
      event => {
        if(me.clicked) {
          me.time = me.originalTime + ((me.origin - event.y) / 25.0)
          me.update()
        }
      })

    this.sub = this.mouseMoveService.mouseUpEvent.subscribe(
      event => {
        if(me.clicked) {
          me.clicked = false
          me.originalTime = undefined
          me.isChangingTimecode = false
        }
      })
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
    this.frames = Math.trunc(frames)
  }

  ngOnChanges(changes: {[propKey: string]: SimpleChange}) {
    if (changes && changes.time) {
      this.time = changes.time.currentValue
      this.update()
    }
  }

  @HostListener('mousedown', ['$event'])
  onMousedown(event) {
    this.clicked = true
    this.origin = event.y
    this.originalTime = this.time

    this.isChangingTimecode = true
  }

  @HostListener('mouseup')
  onMouseup() {
    if(this.time == this.originalTime) {
      let dialogRef = this.dialog.open(TimecodeDialogComponent, {data: this.time})
      dialogRef.afterClosed().subscribe(newTime => {
        if(newTime !== undefined) {
          this.time = newTime;
          this.update()
        }
      })
    }
    this.clicked = false
    this.originalTime = undefined
    this.isChangingTimecode = false
  }
}
