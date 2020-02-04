export class Entity {
    string_ner: String
    type: String[]
    list_id: number[]
    metadata: Metadata
    relevance_score: String
}

export class Metadata {
    wiki_id: String
    freebase_id: String
}

export class Category {
    label: String
    score: String
    category_id: String
}

export class Topic {
    label: String
    score: String
    wiki_id: String
}

export class WordEntity{
    ner: Boolean
    word: String
    entity: Entity
    list_id: number[]

    constructor(word: String, ner: Boolean, entity: Entity, list_id: number[]) {
        this.word = word
        this.entity = entity
        this.ner = ner
        this.list_id = list_id
    }
}
