import { Component } from '@angular/core'
import { ActivatedRoute } from '@angular/router'
import { HttpClient } from '@angular/common/http'
import { S3Service } from '../services/s3.service'
import { WorkflowService } from '../services/workflow.service'
import { Workflow } from '../models/workflow'
import { Entity, Category, Topic } from '../models/nlp_entity'

@Component({
  selector: 'nlp-viewer-component',
  templateUrl: 'nlp_viewer.component.html',
  styleUrls: ['./nlp_viewer.component.less'],
})
export class NlpViewerComponent {
  workflow_id: number
  workflow: Workflow
  entities: Entity[]
  words: string
  categories: Category[]
  topics: Topic[]

  constructor(
    private http: HttpClient,
    private route: ActivatedRoute,
    private workflowService: WorkflowService,
    private s3Service: S3Service,
  ) {}

  ngOnInit() {
    const filename = 'nlp.json'
    this.route.params.subscribe((params) => {
      this.workflow_id = +params['id']
      this.workflowService
        .getWorkflow(this.workflow_id)
        .subscribe((workflowPage) => {
          this.workflow = workflowPage.data
          if (this.workflow.artifacts.length > 0) {
            const file_path = this.getDestinationFilename(
              this.workflow,
              filename,
            )
            const current = this
            if (file_path) {
              this.s3Service
                .getPresignedUrl(file_path)
                .subscribe((response) => {
                  this.http.get(response.url).subscribe((content: any) => {
                    this.entities = content.entity
                    this.words = content.words_list
                    this.categories = content.categories
                    this.topics = content.topics
                  })
                })
            }
          }
        })
    })
  }

  getDestinationFilename(workflow, extension: string, not_extension?: string) {
    const result = workflow.jobs.filter((job) => {
      if (
        (job.name == 'job_transfer' || job.name == 'job_transfer_optim') &&
        job.params.filter((param) => param.id === 'destination_access_key')
          .length == 1
      ) {
        const parameter = job.params.filter(
          (param) => param.id === 'destination_path',
        )
        if (parameter.length > 0) {
          if (not_extension) {
            return (
              parameter[0].value.endsWith(extension) &&
              !parameter[0].value.endsWith(not_extension)
            )
          } else {
            return parameter[0].value.endsWith(extension)
          }
        } else {
          return false
        }
      } else {
        return false
      }
    })
    if (result.length == 0) {
      return undefined
    }
    return result[0].params.filter(
      (param) => param.id === 'destination_path',
    )[0].value
  }

  getEntities(word_index: number): Entity[] {
    var wordEntities: Entity[] = []
    for (var index in this.entities) {
      var entity: Entity = this.entities[index]
      if (entity.list_id.includes(word_index)) {
        wordEntities.push(entity)
      }
    }
    return wordEntities.sort((a, b) => b.list_id.length - a.list_id.length)
  }

  mergedLeft(word: string): boolean {
    return [',', '.', ';'].includes(word) || word.startsWith('-')
  }

  mergedRight(word: string): boolean {
    return word.endsWith('(') || word.endsWith("'") || word.endsWith('-')
  }
}
