import { Component, Inject } from '@angular/core'
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog'

@Component({
  selector: 'timecode_dialog',
  templateUrl: 'timecode_dialog.component.html',
  styleUrls: ['./timecode_dialog.component.less'],
})
export class TimecodeDialogComponent {
  framerate: number = 25.0
  time: number
  hours: number
  minutes: number
  seconds: number
  frames: number

  constructor(
    public dialogRef: MatDialogRef<TimecodeDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any,
  ) {
    this.time = data
    this.update()
  }

  update() {
    var hours = Math.trunc(this.time / 3600)
    var minutes = Math.trunc(this.time / 60 - hours * 60)
    var seconds = Math.trunc(this.time - minutes * 60 - hours * 3600)
    var milli = Math.round(
      1000.0 * (this.time - seconds - minutes * 60 - hours * 3600),
    )
    var frames = (milli * this.framerate) / 1000.0
    this.hours = hours
    this.minutes = minutes
    this.seconds = seconds
    this.frames = Math.trunc(frames)
  }

  onNoClick(): void {
    this.dialogRef.close()
  }

  onClose(): void {
    var time =
      this.hours * 3600 +
      this.minutes * 60 +
      this.seconds +
      this.frames / this.framerate
    this.dialogRef.close(time)
  }
}
