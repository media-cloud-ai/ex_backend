
/* DOCKER HOSTS */

export class HostConfig {
  hostname: string;
  port: number;
}

export class HostsPage {
  data: HostConfig[];
}


/* DOCKER CONTAINERS */

export class Container {
  id: string;
  name: string[];
  state: string;
  status: string;
  image: string;
  docker_host_config: HostConfig;
}

export class ContainersPage {
  data: Container[];
  total: number;
}

export class ContainerConfig {
  Image: string;
  Env: string[];
  HostConfig: Object;
}

export class WorkerContainer {
  name: string;
  label: string;
  params: ContainerConfig;
}
