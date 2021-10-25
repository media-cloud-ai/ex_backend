
import { Parameter } from './workflow'

export class Protocol {
  username: string
  path: string
}

export class Status {
  id: number
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
  last_worker_instance_id: string

  constructor(other: Job) {
    this.id = other.id;
    this.name = other.name;
    this.inserted_at = other.inserted_at;
    this.params = other.params;
    this.status = other.status;
    this.progressions = other.progressions;
  }

  public static getLastStatus(job) {
    return new Job(job).status.sort((s1, s2) => s2.id - s1.id)[0];
  }

  public static getLastProgression(job) {
    return new Job(job).progressions.sort((p1, p2) => p2.id - p1.id)[0];
  }
}

export class Progression {
  id: number
  progression: number
  inserted_at: string
  datetime: string
}
