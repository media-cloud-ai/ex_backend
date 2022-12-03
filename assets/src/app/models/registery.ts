import { User } from './user'

export class Manifest {
  paths: string[]
}

export class Subtitle {
  id: number
  language: string
  index?: number
  version?: string
  inserted_at?: string
  user: User
  path: string
  parent_id?: number
  childs: number[]
  sub_childs: Subtitle[]
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
