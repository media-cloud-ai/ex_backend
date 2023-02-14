export class Entity {
  string_ner: string
  type: string[]
  list_id: number[]
  metadata: Metadata
  relevance_score: string
}

export class Metadata {
  wiki_id: string
  freebase_id: string
}

export class Category {
  label: string
  score: string
  category_id: string
}

export class Topic {
  label: string
  score: string
  wiki_id: string
}
