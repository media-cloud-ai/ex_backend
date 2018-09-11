
export class Manifest {
  paths: string[]
}

export class Subtitle {
  language: string
  paths: string[]
}

export class Params {
  manifests: Manifest[]
  subtitles: Subtitle[]
}

export class Registery {
  id: string
  name: string
  inserted_at: string
  workflow_id: number
  params: Params
}
