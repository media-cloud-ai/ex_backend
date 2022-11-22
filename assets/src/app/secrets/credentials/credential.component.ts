import { Component, EventEmitter, Input, Output } from '@angular/core'

import { CredentialService } from '../../services/credential.service'
import { Credential } from '../../models/credential'
import { PwdType } from '../../models/pwd_type'

@Component({
  selector: 'credential-component',
  templateUrl: 'credential.component.html',
  styleUrls: ['./credential.component.less'],
})
export class CredentialComponent {
  @Input() data: Credential
  @Output() deleted: EventEmitter<Credential> = new EventEmitter<Credential>()

  pwd_type = PwdType.Password

  constructor(private credentialService: CredentialService) {}

  mask(mode) {
    if (mode === true) {
      this.pwd_type = PwdType.Password
    } else {
      this.pwd_type = PwdType.Text
    }
  }

  delete() {
    this.credentialService
      .removeCredential(this.data.id)
      .subscribe((credential) => {
        this.deleted.next(this.data)
      })
  }
}
