import {Component, Inject} from '@angular/core'
import {MatDialogConfig, MatDialogRef, MAT_DIALOG_DATA} from '@angular/material/dialog'
import {UserService} from '../../services/user.service'
import {User} from '../../models/user'

@Component({
  selector: 'user_edition_dialog',
  templateUrl: 'user_edition_dialog.component.html',
  styleUrls: ['./user_edition_dialog.component.less'],
})
export class UserEditionDialogComponent {

  user: User
  new_first_name: string
  new_last_name: string
  user_error_message: string


  constructor(
    private userService: UserService,
    public dialogRef: MatDialogRef<UserEditionDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any) {

    this.user = data.user
  }

  onCancel(): void {
    this.dialogRef.close()
  }

  onValidation(): void {
    this.user_error_message = ''
    console.log(this.new_first_name)
    console.log(this.new_last_name)
    this.userService.updateUser(this.user.id, this.new_first_name, this.new_last_name)
    .subscribe(response => {
      if (response === undefined) {
        this.user_error_message = 'Unable to update user'
      } else {
        this.new_first_name = ''
        this.new_last_name = ''
      }
    })
    this.dialogRef.close()
  }
}
