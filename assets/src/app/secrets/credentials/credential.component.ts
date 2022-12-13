import { Component, EventEmitter, Input, Output } from '@angular/core'
import { MatSnackBar } from '@angular/material/snack-bar'

import {
  Credential,
  CredentialEventAction,
  CredentialEvent,
} from '../../models/credential'
import { CredentialsComponent } from './credentials.component'
import { CredentialService } from '../../services/credential.service'
import { PwdType } from '../../models/pwd_type'

@Component({
  selector: 'credential-component',
  templateUrl: 'credential.component.html',
  styleUrls: ['./credential.component.less'],
})
export class CredentialComponent {
  @Input() data: Credential
  @Input() selected_credential: number
  @Output() deleted: EventEmitter<Credential> = new EventEmitter<Credential>()
  @Output() credentialChange = new EventEmitter<CredentialEvent>()

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

  edit(is_edited) {
    if (is_edited === true) {
      this.disabled = false
      this.selectCredential()
    } else {
      this.disabled = true
      this.saveCredential()
      this.credentialService
        .changeCredential(this.data.id, this.data.key, this.data.value)
        .subscribe((credential) => {
          if (!credential) {
            if (!this.data.key || !this.data.value) {
              const _snackBarRef = this.snackBar.open(
                'You must not leave Key or Value field empty!',
                '',
                {
                  duration: 3000,
                },
              )
            }
            if (!this.data.key.trim() || !this.data.value.trim()) {
              const _snackBarRef = this.snackBar.open(
                'You must not fill Key or Value field with whitespaces!',
                '',
                {
                  duration: 3000,
                },
              )
            }
          }
        })
      this.credentialsComponent.listCredentials()
    }
  }

  delete() {
    this.credentialService
      .removeCredential(this.data.id)
      .subscribe((_credential) => {
        this.deleted.next(this.data)
      })
    this.saveCredential()
  }

  selectCredential() {
    this.credentialChange.emit(
      new CredentialEvent(CredentialEventAction.Select, this.data),
    )
  }

  saveCredential() {
    this.credentialChange.emit(
      new CredentialEvent(CredentialEventAction.Save, this.data),
    )
  }
}
