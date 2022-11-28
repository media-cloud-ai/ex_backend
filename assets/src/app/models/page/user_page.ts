import { User, Role } from '../user'

export class UserPage {
  data: User[]
  total: number
}

export class RolePage {
  data: Role[]
  total: number
}

export class RightDefinitionsPage {
  endpoints: string[]
  rights: string[]
}
