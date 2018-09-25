
export class Manifest {
  paths: string[]
}

export class Subtitle {
  language: string
  index?: number
  paths: string[]
}

export class Params {
  manifests: Manifest[]
  subtitles: Subtitle[]
}

export class Registery {
  id: number
  name: string
  inserted_at: string
  workflow_id: number
  params: Params
}
