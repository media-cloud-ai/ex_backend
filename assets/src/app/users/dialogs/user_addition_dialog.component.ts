import { Component, Inject } from '@angular/core'
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog'
import { UserService } from '../../services/user.service'
import { User } from '../../models/user'
import { FormControl, Validators } from '@angular/forms'

@Component({
  selector: 'user_addition_dialog',
  templateUrl: './user_addition_dialog.component.html',
  styleUrls: ['./user_addition_dialog.component.less'],
})
export class UserAdditionDialogComponent {
  user: User
  user_error_message: string
  email = new FormControl('', [Validators.required, Validators.email])
  first_name = new FormControl('', [Validators.required])
  last_name = new FormControl('', [Validators.required])

  constructor(
    private userService: UserService,
    public dialogRef: MatDialogRef<UserAdditionDialogComponent>,
  ) {}

  getErrorMessage() {
    if (this.email.hasError('required')) {
      return 'You must enter a value'
    }
    return this.email.hasError('email') ? 'Not a valid email' : ''
  }

  getEmptyMessage(elem) {
    if (elem.hasError('required')) {
      return 'You must enter a value'
    }
  }
  onClose(): void {
    this.dialogRef.close()
  }

  onValidation(): void {
    this.user_error_message = ''
    console.log(this.first_name)
    console.log(this.last_name)
    console.log(this.email)
    if (
      this.email.invalid ||
      this.first_name.invalid ||
      this.last_name.invalid
    ) {
      return
    } else {
      this.userService
        .inviteUser(
          this.email.value,
          this.first_name.value,
          this.last_name.value,
        )
        .subscribe((response) => {
          if (response === undefined) {
            this.user_error_message = 'Unable to create user'
          } else {
            this.dialogRef.close()
          }
        })
    }
  }
}
