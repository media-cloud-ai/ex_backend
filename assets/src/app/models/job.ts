
export class Protocol {
  username: string;
  path: string;
}

export class Status {
  state: string;
  inserted_at: string;
}

export class Job {
  id: string;
  name: string;
  inserted_at: string;
  params: object;
  status: Status[];
}
