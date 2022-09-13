import {Component, Inject} from '@angular/core'
import {MatDialogConfig, MatDialogRef, MAT_DIALOG_DATA} from '@angular/material/dialog'
import {User} from '../../models/user'
import { Clipboard } from "@angular/cdk/clipboard";

@Component({
  selector: 'user_show_credentials_dialog',
  templateUrl: 'user_show_credentials_dialog.component.html',
  styleUrls: ['./user_show_credentials_dialog.component.less'],
})
export class UserShowCredentialsDialogComponent {

  user: User
  type: string

  constructor(
    public dialogRef: MatDialogRef<UserShowCredentialsDialogComponent>,
    private clipboard: Clipboard,
    @Inject(MAT_DIALOG_DATA) public data: any) {

    this.user = data.user.data
    this.type = data.message
  }

  CopySecretKey() {
    this.clipboard.copy(this.user.secret_access_key)
  }

  onClose(): void {
    this.dialogRef.close()
  }
}
