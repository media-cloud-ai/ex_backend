
import { NodeConfig } from './node_config';

export class Container {
  id: string;
  name: string[];
  state: string;
  status: string;
  image: string;
  node_config: NodeConfig;
}
