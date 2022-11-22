import { Component, Inject } from '@angular/core'
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog'
import { Role, Right } from '../../models/user'

@Component({
  selector: 'role_or_right_deletion_dialog',
  templateUrl: 'role_or_right_deletion_dialog.component.html',
  styleUrls: ['./role_or_right_deletion_dialog.component.less'],
})
export class RoleOrRightDeletionDialogComponent {
  role: Role
  right: Right

  constructor(
    public dialogRef: MatDialogRef<RoleOrRightDeletionDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any,
  ) {
    this.role = data.role
    this.right = data.right
  }

  onClose(confirm: boolean): void {
    this.dialogRef.close(confirm)
  }
}
