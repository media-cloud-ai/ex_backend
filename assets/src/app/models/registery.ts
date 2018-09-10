
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
  workflow_id: number
  params: Params
}
