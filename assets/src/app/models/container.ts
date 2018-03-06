
import { HostConfig } from './host_config';

export class Container {
  id: string;
  name: string[];
  state: string;
  status: string;
  image: string;
  docker_host_config: HostConfig;
}
