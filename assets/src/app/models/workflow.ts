
export class JobsStatus {
  completed: number
  errors: number
  queued: number
  stopped: number
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
  focus?: boolean
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
  label?: string
  version_major?: string
  version_minor?: string
  version_micro?: string
  is_live?: boolean
  tags?: string[]
  reference?: string
  created_at?: string
  artifacts?: Artifact[]
  rights?: Right[]
  steps?: Step[]
  workflow_id?: number
  user_uuid?: string

  static compare(a: Workflow, b: Workflow) {
    let identifierComparison = a.identifier.localeCompare(b.identifier);

    if (identifierComparison != 0) {
      return identifierComparison;
    }

    let a_version = new Version(a);
    let b_version = new Version(b);

    return Version.compare(a_version, b_version);
  }
}

export class WorkflowEvent {
  event: string
  job_id?: string
}

export class Version {
  major: number
  minor: number
  micro: number

  constructor(workflow: Workflow) {
    this.major = parseInt(workflow.version_major)
    this.minor = parseInt(workflow.version_minor)
    this.micro = parseInt(workflow.version_micro)
  }

  public equals(other: Version) : boolean {
      return this.major === other.major && this.minor === other.minor && this.minor === other.minor;
  }

  static compare(a: Version, b: Version) {
    let diff = a.major - b.major;
    if (diff != 0) {
      return diff;
    }

    diff = a.minor - b.minor;
    if (diff != 0) {
      return diff;
    }

    diff = a.micro - b.micro;
    if (diff != 0) {
      return diff;
    }

    return 0;
  }

  public toString = () : string => {
      return this.major + "." + this.minor + "." + this.micro;
  }
}

export class SimpleWorkflowDefinition {
  identifier: string
  versions: Version[]

  constructor(workflow: Workflow) {
    this.identifier = workflow.identifier;
    this.versions = [];
    this.versions.push(new Version(workflow));
  }

  public addVersion(version: Version) {
    this.versions.push(version);
    this.versions.sort(Version.compare);
  }
}
