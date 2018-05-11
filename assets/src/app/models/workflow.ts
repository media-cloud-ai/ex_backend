
export class JobsStatus {
  completed: number;
  errors: number;
  queued: number;
  skipped: number;
  total: number;
}

export class Parameter {
  id: string;
  type: string;
  default: any;
  value: any;
}

export class Step {
  id: number;
  parent_ids?: number[];
  name: string;
  enable: boolean;
  status?: string;
  required?: string[];
  parameters?: Parameter[];
  jobs?: JobsStatus;
}

export class Flow {
  steps: Step[];
}

export class Artifact {
  resources: any;
}

export class Workflow {
  id?: number;
  reference: string;
  created_at?: string;
  artifacts?: Artifact;
  flow: Flow;
}

export class WorkflowEvent {
  event: string;
}
