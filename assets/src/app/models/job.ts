
import { Parameter } from './workflow'

export class Protocol {
  username: string
  path: string
}

export class Status {
  state: string
  inserted_at: string
}

export class Job {
  id: string
  name: string
  inserted_at: string
  params: Parameter[]
  status: Status[]
  progressions: Progression[]
}

export class Progression {
  progression: number
  inserted_at: string
  datetime: string
}
