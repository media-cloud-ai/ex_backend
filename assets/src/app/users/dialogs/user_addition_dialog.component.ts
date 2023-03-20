import { Component, Inject } from '@angular/core'
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog'
import { UserService } from '../../services/user.service'
import { User } from '../../models/user'

@Component({
  selector: 'user_addition_dialog',
  templateUrl: './user_addition_dialog.component.html',
  styleUrls: ['./user_addition_dialog.component.less'],
})
export class UserAdditionDialogComponent {
  user: User
  first_name: string
  last_name: string
  email: string
  user_error_message: string

  constructor(
    private userService: UserService,
    public dialogRef: MatDialogRef<UserAdditionDialogComponent>,
  ) {}

  onClose(): void {
    this.dialogRef.close()
  }

  onValidation(): void {
    this.user_error_message = ''
    console.log(this.first_name)
    console.log(this.last_name)
    console.log(this.email)
    this.userService
      .inviteUser(this.email, this.first_name, this.last_name)
      .subscribe((response) => {
        if (response === undefined) {
          this.user_error_message = 'Unable to create user'
        } else {
          this.email = ''
          this.first_name = ''
          this.last_name = ''
        }
      })
    this.dialogRef.close()
  }
}
