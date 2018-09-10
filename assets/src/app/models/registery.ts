
export class Manifest {
  paths: string[]
}

export class Params {
  manifests: Manifest[]
}

export class Registery {
  id: string
  name: string
  inserted_at: string
  params: Params
}
