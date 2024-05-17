export class Application {
  identifier: string
  label: string
  logo: string
  version: string
  providers: Array<Provider>
}

export class Provider {
  id: string
  layout: Layout
  enabled: boolean
}

export class Layout {
  logo: string
  display_name: string
}
