import { Component, Inject } from '@angular/core'
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog'
import { User } from '../../models/user'

@Component({
  selector: 'user_deletion_dialog',
  templateUrl: 'user_deletion_dialog.component.html',
  styleUrls: ['./user_deletion_dialog.component.less'],
})
export class UserDeletionDialogComponent {
  user: User

  constructor(
    public dialogRef: MatDialogRef<UserDeletionDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any,
  ) {
    this.user = data.user
  }

  onClose(confirm: boolean): void {
    this.dialogRef.close(confirm)
  }
}
