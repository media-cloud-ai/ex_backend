
export class JobsStatus {
  completed: number
  errors: number
  queued: number
  skipped: number
  total: number
}

export class Parameter {
  id: string
  type: string
  enable?: boolean
  default: any
  value: any
}

export class Input {
  path: string
  agent?: string
}

export class Step {
  id: number
  parent_ids?: number[]
  name: string
  label?: string
  icon?: string
  enable: boolean
  status?: string
  required?: number[]
  inputs?: Input[]
  output_extension?: string
  parameters?: Parameter[]
  jobs?: JobsStatus
}

export class Artifact {
  resources: any
}

export class Right {
  action: string
  groups: string[]
}

export class Workflow {
  id?: number
  identifier?: string
  version_major?: string
  version_minor?: string
  version_micro?: string
  is_live?: boolean
  tags?: string[]
  reference?: string
  created_at?: string
  artifacts?: Artifact[]
  rights: Right[]
  steps: Step[]
  workflow_id?: number
}

export class WorkflowEvent {
  event: string
  job_id?: string
}
