
export class Parameter {
  id: string;
  type: string;
  default: any;
  value: any;
}

export class Step {
  id: string;
  parameters: Parameter[];
}

export class Flow {
  steps: Step[];
}

export class Workflow {
  reference: string;
  flow: Flow;
}
