

export class JobDuration {
  job_id: number
  workflow_id: number
  order_pending: number
  processing: number
  response_pending: number
  total: number
}

export class JobDurations {
  data: JobDuration[]
  page: number
  size: number
  total: number
}

export class WorkflowDuration {
  workflow_id: number
  order_pending: number
  processing: number
  response_pending: number
  total: number
}

export class WorkflowDurations {
  data: WorkflowDuration[]
  page: number
  size: number
  total: number
}
