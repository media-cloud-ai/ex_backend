
import {Component} from '@angular/core'
import {ActivatedRoute} from '@angular/router'

import {CredentialService} from '../services/credential.service'
import {Credential} from '../models/credential'

@Component({
  selector: 'credentials-component',
  templateUrl: 'credentials.component.html',
  styleUrls: ['./credentials.component.less'],
})

export class CredentialsComponent {
  credentials: Credential[]

  key: string
  value: string

  constructor(
    private route: ActivatedRoute,
    private credentialService: CredentialService,
  ) {}

  ngOnInit() {
    this.listCredentials()
  }

  listCredentials() {
    this.credentialService.getCredentials()
    .subscribe(credentialPage => {
      this.credentials = credentialPage.data.sort((a, b) => (a.key > b.key) ? 1 : ((b.key > a.key) ? -1 : 0));
    })
  }

  insert() {
    this.credentialService.createCredential(this.key, this.value)
    .subscribe(credentialPage => {
      this.listCredentials()
    })
  }
}
