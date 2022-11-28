export class McaiDurations {
  order_pending: number
  processing: number
  response_pending: number
  total: number
}

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

export class DurationStatistics {
  average: McaiDurations
  count: number
  max: McaiDurations
  min: McaiDurations
}

export class WorkflowDurationStatistics {
  data: WorkflowDurationStatisticsEntry[]
  page: number
  size: number
  total: number
}

export class WorkflowDurationStatisticsEntry {
  name: string
  version: string
  durations: DurationStatistics
}

export class JobDurationStatistics {
  data: JobDurationStatisticsEntry[]
  page: number
  size: number
  total: number
}

export class JobDurationStatisticsEntry {
  name: string
  durations: DurationStatistics
}
