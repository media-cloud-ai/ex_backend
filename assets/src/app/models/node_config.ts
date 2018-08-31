
export class NodeConfig {
  id?: string
  label: string
  hostname: string
  port: number
  ssl_enabled: boolean
  cacertfile?: string
  certfile?: string
  keyfile?: string
}
