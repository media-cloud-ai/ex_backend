import { Workflow } from '../workflow'

export class WorkflowPage {
  data: Workflow[]
  total: number
}

export class WorkflowData {
  data: Workflow
}

export class WorkflowHistory {
  data: WorkflowHistoryData
}

export class WorkflowHistoryData {
  bins: WorkflowHistoryBin[]
  completed: number
  error: number
  processing: number
}

export class WorkflowHistoryBin {
  bin: number
  completed: number
  end_date: string
  error: number
  processing: number
  start_date: string
}

export class WorkflowQueryParams {
  identifiers: string[]
  mode: string[]
  start_date: any
  end_date: any
  search?: string
  status: string[]
  detailed: boolean
  time_interval: number
}
