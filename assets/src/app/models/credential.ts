export class Credential {
  id: number
  key: string
  value: string
  inserted_at: string
}

export enum CredentialEventAction {
  Select,
  Save,
}

export class CredentialEvent {
  action: CredentialEventAction
  credential: Credential

  constructor(action: CredentialEventAction, credential: Credential) {
    this.action = action
    this.credential = credential
  }
}
