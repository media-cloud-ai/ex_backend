export class NlpEntity{
    token: String
    ner: Boolean
    string_ner: String
    id_ner: Int16Array
    type: String[]
    metadata_wiki: String
    metadata_freebase: String
    relevance_score: Float32Array

    newline: Boolean

    constructor() {
        this.type = new Array<string>('')
        this.newline = false
        this.ner = false
    }
  }