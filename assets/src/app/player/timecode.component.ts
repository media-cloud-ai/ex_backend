import {
  Component,
  EventEmitter,
  HostListener,
  Input,
  Output,
  OnChanges,
  SimpleChange,
} from '@angular/core'
import { MatDialog } from '@angular/material/dialog'

import { Subscription } from 'rxjs'

import { MouseMoveService } from '../services/mousemove.service'
import { TimecodeDialogComponent } from './dialog/timecode_dialog.component'

@Component({
  selector: 'timecode-component',
  templateUrl: 'timecode.component.html',
  styleUrls: ['./timecode.component.less'],
})
export class TimecodeComponent implements OnChanges {
  @Input() time: number
  @Input() framerate = 25.0
  @Input() isChangingTimecode: boolean

  @Output() timeChange: EventEmitter<number> = new EventEmitter<number>()

  private originalTime: number

  private hours: number
  private minutes: number
  private secondes: number
  private frames: number

  private clicked = false
  private origin: number
  private last: MouseEvent

  private sub: Subscription

  constructor(
    private mouseMoveService: MouseMoveService,
    public dialog: MatDialog,
  ) {}

  ngOnInit() {
    this.update()
    const current = this

    this.sub = this.mouseMoveService.mouseMoveEvent.subscribe((event) => {
      if (current.clicked) {
        current.time = Math.max(
          current.originalTime + (current.origin - event.y) / 25.0,
          0.0,
        )
        current.update()
      }
    })

    this.sub = this.mouseMoveService.mouseUpEvent.subscribe((_event) => {
      if (current.clicked) {
        current.clicked = false
        current.originalTime = undefined
        current.isChangingTimecode = false
      }
    })
  }

  update() {
    const hours = Math.trunc(this.time / 3600)
    const minutes = Math.trunc(this.time / 60 - hours * 60)
    const seconds = Math.trunc(this.time - minutes * 60 - hours * 3600)
    const milli = Math.round(
      1000.0 * (this.time - seconds - minutes * 60 - hours * 3600),
    )
    const frames = (milli * this.framerate) / 1000.0
    this.hours = hours
    this.minutes = minutes
    this.secondes = seconds
    this.frames = Math.trunc(frames)
    this.timeChange.next(this.time)
  }

  ngOnChanges(changes: { [propKey: string]: SimpleChange }) {
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
    if (this.time == this.originalTime) {
      const dialogRef = this.dialog.open(TimecodeDialogComponent, {
        data: this.time,
      })
      dialogRef.afterClosed().subscribe((newTime) => {
        if (newTime !== undefined) {
          this.time = newTime
          this.update()
        }
      })
    }
    this.clicked = false
    this.originalTime = undefined
    this.isChangingTimecode = false
  }
}
