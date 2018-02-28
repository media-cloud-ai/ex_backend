
export class Container {
  id: string;
  name: string[];
  state: string;
  status: string;
  image: string;
  host: Host;
}

export class ContainersPage {
  data: Container[];
  total: number;
}

export class Host {
  name: string;
  port: number;
  protocol: string;
}

export class HostConfig {
  host: string;
  port: number;
  ssl: boolean;
}

export class HostsPage {
  data: HostConfig[];
}

export class WorkerContainer {
  name: string;
  label: string;
  params: {};
}

export class ContainerResponse {
  id: string;
  message: string;
  warning: string;
}
