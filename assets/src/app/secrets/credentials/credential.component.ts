import { Component, EventEmitter, Input, Output } from '@angular/core'

import { CredentialService } from '../../services/credential.service'
import { Credential } from '../../models/credential'
import { PwdType } from '../../models/pwd_type'
import { MatSnackBar } from '@angular/material/snack-bar'
import { CredentialsComponent } from './credentials.component'

@Component({
  selector: 'credential-component',
  templateUrl: 'credential.component.html',
  styleUrls: ['./credential.component.less'],
})
export class CredentialComponent {
  @Input() data: Credential
  @Output() deleted: EventEmitter<Credential> = new EventEmitter<Credential>()

  pwd_type = PwdType.Password
  disabled = true
  constructor(
    private credentialsComponent: CredentialsComponent,
    private credentialService: CredentialService,
    private snackBar: MatSnackBar,
  ) {}

  mask(mode) {
    if (mode === true) {
      this.pwd_type = PwdType.Password
    } else {
      this.pwd_type = PwdType.Text
    }
  }

  edit(mode) {
    if (mode == true) {
      this.disabled = false
    } else {
      this.disabled = true
      this.credentialService.changeCredential(
        this.data.id,
        this.data.key,
        this.data.value,
      )
      if (!this.data.key || !this.data.value) {
        const _snackBarRef = this.snackBar.open(
          'You must not leave Key or Value field empty !',
          '',
          {
            duration: 3000,
          },
        )
      } else {
        const _snackBarRef = this.snackBar.open(
          'Error while editing Credential value or key.',
          '',
          {
            duration: 3000,
          },
        )
      }
      this.credentialsComponent.listCredentials()
    }
  }

  delete() {
    this.credentialService
      .removeCredential(this.data.id)
      .subscribe((_credential) => {
        this.deleted.next(this.data)
      })
  }
}
