
export class Info {
  detail: string
}

export class Confirm {
  info: Info
}

export class Right {
  entity: string
  action: string[]

  constructor() {
    this.action = [];
  }
}

export class Role {
  id?: number
  name: string
  rights: Right[];

  constructor(name: string) {
    this.name = name;
    this.rights = [];
  }
}

export enum RoleEventAction {
  Update,
  Delete
}

export class RoleEvent {
  action: RoleEventAction
  role: Role

  constructor(action: RoleEventAction, role: Role) {
    this.action = action;
    this.role = role;
  }
}

export class ValidationLink{
  validation_link: string
}

export class User {
  email: string
  inserted_at: string
  confirmed_at: string
  password: string
  roles: string[]
  id: number
  uuid: string
  access_key_id: string
  secret_access_key: string
  first_name: string
  last_name: string
  username: string
}
