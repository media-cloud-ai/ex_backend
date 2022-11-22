import { Component, Inject } from '@angular/core'
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog'

@Component({
  selector: 'delete_subtitle_dialog',
  templateUrl: 'delete_subtitle_dialog.component.html',
  styleUrls: ['./delete_subtitle_dialog.component.less'],
})
export class DeleteSubtitleDialog {
  constructor(
    public dialogRef: MatDialogRef<DeleteSubtitleDialog>,
    @Inject(MAT_DIALOG_DATA) public data: any,
  ) {}

  onNoClick(): void {
    this.dialogRef.close(false)
  }

  onClose(): void {
    this.dialogRef.close(true)
  }
}
