import {Component, Inject} from '@angular/core'
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material/dialog'

@Component({
  selector: 'set_version_dialog',
  templateUrl: 'set_version_dialog.html',
  styleUrls: ['./set_version_dialog.less'],
})

export class SetVersionDialog {
  version: string
  constructor(
    public dialogRef: MatDialogRef<SetVersionDialog>,
    @Inject(MAT_DIALOG_DATA) public data: string) {
    this.version = data
  }

  onNoClick(): void {
    this.dialogRef.close()
  }

  onClose(): void {
    this.dialogRef.close(this.version)
  }
}
