import { Job } from './job'


export class JobsStatus {
  completed: number
  dropped: number
  errors: number
  queued: number
  stopped: number
  skipped: number
  total: number
}

export class Status {
  id: number
  state: string
  description?: string
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

export class NotificationStatus {
  condition?: string
  response?: any
  timestamp?: string
}

export class NotificationHook {
  label?: string
  endpoint?: string
  credentials?: string
  status?: NotificationStatus[]
}

export class Workflow {
  id?: number
  identifier?: string
  label?: string
  version_major?: string
  version_minor?: string
  version_micro?: string
  is_live?: boolean
  deleted?: boolean
  jobs?: Array<Job>
  tags?: string[]
  reference?: string
  created_at?: string
  artifacts?: Artifact[]
  rights?: Right[]
  status?: Status
  steps?: Step[]
  workflow_id?: number
  user_uuid?: string
  notification_hooks?: Array<NotificationHook>

  static compare(a: Workflow, b: Workflow) {
    let identifierComparison = a.identifier.localeCompare(b.identifier);

    if (identifierComparison != 0) {
      return identifierComparison;
    }

    let a_version = Version.from_workflow(a);
    let b_version = Version.from_workflow(b);

    return Version.compare(a_version, b_version);
  }

  public is_paused(): boolean {
    return ["pausing", "paused"].includes(this.status.state);
  }

  public is_stopped(): boolean {
    return ["stopped"].includes(this.status.state);
  }

  public is_finished(): boolean {
    return this.artifacts.length > 0;
  }

  has_at_least_one_queued_job(): boolean {
    return this.steps.some((s) => s['jobs']['queued'] == 1);
  }

  has_at_least_one_processing_step(): boolean {
    return this.steps.some((s) => s['status'] === "processing");
  }

  public can_abort(): boolean {
    return !this.is_stopped() && (this.has_at_least_one_processing_step() || this.is_paused());
  }

  public can_pause(): boolean {
    let last_step = this.steps[this.steps.length - 1];
    let is_last_step_processing = last_step['jobs']['processing'] == 1;

    return !this.is_finished() && !this.is_stopped() && (this.has_at_least_one_queued_job() || this.has_at_least_one_processing_step()) && !this.is_paused() && !is_last_step_processing;
  }

  public can_resume(): boolean {
    let has_at_least_one_paused_step = this.steps.some((s) => s['status'] === "paused");
    return has_at_least_one_paused_step && !this.is_finished() && !this.is_stopped();
  }

  public can_delete(): boolean {
    return !this.deleted;
  }


}

export class WorkflowEvent {
  event: string
  job_id?: string
  post_action?: string
  trigger_at?: number
}

export class Version {
  major: number
  minor: number
  micro: number

  constructor(major: number, minor: number, micro: number) {
    this.major = major;
    this.minor = minor;
    this.micro = micro;
  }

  static from_workflow(workflow: Workflow): Version {
    return new Version(
      parseInt(workflow.version_major),
      parseInt(workflow.version_minor),
      parseInt(workflow.version_micro));
  }

  static from_string(value: string): Version {
    let items = value.split(".");
    if (items.length != 3) {
      console.error("Invalid version string", value);
      return undefined;
    }
    return new Version(
      parseInt(items[0]),
      parseInt(items[1]),
      parseInt(items[2]));
  }

  public equals(other: Version) : boolean {
      return this.major === other.major && this.minor === other.minor && this.micro === other.micro;
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
