import { Workflow } from '../workflow'
import {Role, RoleEventAction} from "../user";

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
  selectedDateRange: {
    startDate: any
    endDate: any
  }
  search?: string
  status: string[]
  detailed: boolean
  refresh_interval: number
  time_interval: number
}

export enum ViewOption {
  Detailed,
  RefreshInterval,
}

export class ViewOptionEvent {
  option: ViewOption
  value: any

  constructor(option: ViewOption, value: any) {
    this.option = option;
    this.value = value;
  }
}