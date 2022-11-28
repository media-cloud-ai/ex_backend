import { Component, Inject } from '@angular/core'
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog'

import { AuthService } from '../../authentication/auth.service'

@Component({
  selector: 'enter_email_dialog-component',
  templateUrl: 'enter_email_dialog.component.html',
  styleUrls: ['./enter_email_dialog.component.less'],
})
export class EnterEmailDialogComponent {
  email: string
  message: string
  message_color: string

  constructor(
    private authService: AuthService,
    public dialogRef: MatDialogRef<EnterEmailDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any,
  ) {
    this.email = data.user
    this.message = data.message
    this.message_color = 'black'
  }

  resetPassword(): void {
    this.authService
      .passwordResetRequest(this.email)
      .subscribe((passwordReset) => {
        if (passwordReset.error != null) {
          console.log(passwordReset)
          this.message = passwordReset.error
          this.message_color = 'red'
        } else {
          this.message = passwordReset.detail
          this.message_color = 'black'
        }
      })
  }

  onClose(): void {
    this.dialogRef.close()
  }
}
