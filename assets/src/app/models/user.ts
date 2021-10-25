
export class Info {
  detail: string
}

export class Confirm {
  info: Info
}

export class User {
  email: string
  inserted_at: string
  password: string
  rights: any
  id: number
  uuid: string
  access_key_id: string
  secret_access_key: string
}
