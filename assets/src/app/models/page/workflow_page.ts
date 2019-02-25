import { Workflow } from '../workflow'

export class WorkflowPage {
  data: Workflow[]
  total: number
}

export class WorkflowData {
  data: Workflow
}

export class WorkflowHistory {
  data: WorkflowHistoryStep[]
}

export class WorkflowHistoryStep {
  total: number
}
