
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
  required?: string[];
  parameters?: Parameter[];
}

export class Flow {
  steps: Step[];
}

export class Artifact {
  resources: any;
}

export class Workflow {
  reference: string;
  created_at?: string;
  artifacts?: Artifact;
  flow: Flow;
}
