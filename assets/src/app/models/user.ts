
export class Info {
  detail: string
}

export class Confirm {
  info: Info
}

export class Right {
  entity: string
  action: string[]
}

export class Role {
  name: string
  rights: Right[]
}

export class User {
  email: string
  inserted_at: string
  password: string
  roles: string[]
  id: number
  uuid: string
  access_key_id: string
  secret_access_key: string
}
