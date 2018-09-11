import {Component, Inject} from '@angular/core'
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material'

@Component({
  selector: 'new_subtitle_dialog',
  templateUrl: 'new_subtitle_dialog.component.html',
  styleUrls: ['./new_subtitle_dialog.component.less'],
})

export class NewSubtitleDialogComponent {
  language: any
  languages = [
    {language: "eng"},
    {language: "fra"},
    {language: "deu"},
    {language: "spa"},
    {language: "ita"},
  ]

  constructor(
    public dialogRef: MatDialogRef<TimecodeDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any) {
  }

  onNoClick(): void {
    this.dialogRef.close()
  }

  onClose(): void {
    this.dialogRef.close(this.language)
  }
}
