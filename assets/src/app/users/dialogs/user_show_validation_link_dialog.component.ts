import { Component, Inject } from '@angular/core'
import {
  MatDialogConfig,
  MatDialogRef,
  MAT_DIALOG_DATA,
} from '@angular/material/dialog'
import { UserService } from '../../services/user.service'
import { User, ValidationLink } from '../../models/user'
import { Clipboard } from '@angular/cdk/clipboard'

@Component({
  selector: 'user_show_validation_link_dialog',
  templateUrl: 'user_show_validation_link_dialog.component.html',
  styleUrls: ['./user_show_validation_link_dialog.component.less'],
})
export class UserShowValidationLinkDialogComponent {
  user: User
  type: string
  validation_link: string

  constructor(
    private userService: UserService,
    private clipboard: Clipboard,
    public dialogRef: MatDialogRef<UserShowValidationLinkDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any,
  ) {
    console.log(data)
    this.user = data.user
    this.type = data.message
    this.validation_link = data.validation_link.validation_link
  }

  CopyValidationLink() {
    this.clipboard.copy(this.validation_link)
  }

  onClose(): void {
    this.dialogRef.close()
  }
}
