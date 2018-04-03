
import { NodeConfig } from './node_config';

export class ImageParameters {
  Image: string;
  Env: string[];
  HostConfig: Object;
}

export class Image {
  id: string;
  label: string;
  node_config: NodeConfig;
  params: ImageParameters
}
