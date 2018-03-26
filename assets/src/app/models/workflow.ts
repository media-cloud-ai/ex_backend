
export class Parameter {
  id: string;
  type: string;
  default: any;
  value: any;
}

export class Step {
  id: string;
  enable: boolean;
  parameters: Parameter[];
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
