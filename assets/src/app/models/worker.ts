
export class Worker {
  id: number
}

export class WorkerStatus {
  id: string
  name: string
  version: string
  activity: string
  current_job?: number
  job_status?: string

  constructor(id: string, name: string, version: string, activity: string) {
    this.id = id;
    this.name = name;
    this.version = version;
    this.activity = activity;
  }
}

