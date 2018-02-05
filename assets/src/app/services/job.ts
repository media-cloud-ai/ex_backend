

export class Protocol {
  username: string;
  path: string;
}

export class Status {
  state: string;
  inserted_at: string;
}

export class Parameters {
  source: Protocol;
  destination: Protocol;
}

export class Job {
  id: string;
  name: string;
  inserted_at: string;
  status: Status[];
  params: Parameters
}
