

export class Ssl {
  cert_file?: string;
  key_file?: string;
}

export class NodeConfig {
  label: string;
  hostname: string;
  port: number;
  ssl: Ssl;
}
