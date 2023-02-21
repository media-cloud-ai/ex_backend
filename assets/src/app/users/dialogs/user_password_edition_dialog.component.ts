import { Component, Inject } from '@angular/core'
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog'
import { UserService } from '../../services/user.service'
import { User } from '../../models/user'

@Component({
  selector: 'user_password_edition_dialog',
  templateUrl: 'user_password_edition_dialog.component.html',
  styleUrls: ['./user_password_edition_dialog.component.less'],
})
export class UserPasswordEditionDialogComponent {
  user: User
  password: string
  hide = true

  constructor(
    private userService: UserService,
    public dialogRef: MatDialogRef<UserPasswordEditionDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any,
  ) {
    this.user = data.user
  }

  onCancel(): void {
    this.password = ''
    this.dialogRef.close()
  }

  onValidation(): void {
    this.userService
      .changeUserPassword(this.user, this.password)
      .subscribe((_response) => {
        this.password = ''
      })
    this.dialogRef.close()
  }
}
