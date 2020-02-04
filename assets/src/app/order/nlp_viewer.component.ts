import { Component, ViewChild } from '@angular/core'
import { ActivatedRoute } from '@angular/router'
import { HttpClient } from '@angular/common/http'
import { S3Service } from '../services/s3.service'
import { WorkflowService } from '../services/workflow.service'
import { Workflow } from '../models/workflow'
import { Entity, Category, Topic, WordEntity} from '../models/nlp_entity'

@Component({
  selector: 'nlp-viewer-component',
  templateUrl: 'nlp_viewer.component.html',
  styleUrls: ['./nlp_viewer.component.less'],
})

export class NlpViewerComponent {
  workflow_id: number;
  workflow: Workflow;
  entities: Entity[];
  words: WordEntity[];
  categories: Category[];
  topics: Topic[];

  constructor(
    private http: HttpClient,
    private route: ActivatedRoute,
    private workflowService: WorkflowService,
    private s3Service: S3Service,
  ) { }

  ngOnInit() {
    const filename = 'nlp.json';
    this.route
      .params
      .subscribe(params => {
        this.workflow_id = +params['id']
        this.workflowService.getWorkflow(this.workflow_id)
          .subscribe(workflowPage => {
            this.workflow = workflowPage.data;
            if (this.workflow.artifacts.length > 0) {
              const file_path = this.getDestinationFilename(this.workflow, filename);
              const current = this
              if (file_path) {
                this.s3Service.getPresignedUrl(file_path).subscribe(response => {
                  this.http.get(response.url).subscribe((content: any) => {
                    this.entities = content.entity
                    this.categories = content.categories
                    this.topics = content.topics
                    this.words = this.getListOfWordEntity(content.words_list);
                  })
                });
              }
            }
          });
      })
  }

  getDestinationFilename(workflow, extension: string, not_extension?: string) {
    const result = workflow.jobs.filter(job => {
      if (job.name == "job_transfer" &&
        job.params.filter(param => param.id === "destination_access_key").length == 1) {
        const parameter = job.params.filter(param => param.id === "destination_path");
        if (parameter.length > 0) {
          if (not_extension) {
            return parameter[0].value.endsWith(extension) && !parameter[0].value.endsWith(not_extension)
          } else {
            return parameter[0].value.endsWith(extension)
          }
        } else {
          return false
        }
      } else {
        return false
      }
    });
    if (result.length == 0) {
      return undefined;
    }
    return result[0].params.filter(param => param.id === "destination_path")[0].value;
  }

  content(wordEntities : WordEntity[], word_index : number){


  }

  getListOfWordEntity(words: string[]) {
    console.log(this.entities);
    var len_entities = this.entities.length;
    var i_entity = 0;
    var wordEntities = [];
    for (var word in words) {
        if (i_entity < len_entities && this.entities[i_entity].list_id[0] <= word) {
            var entity = this.entities[i_entity];
            wordEntities.push(new WordEntity(entity.string_ner, true, entity, entity.list_id));
            i_entity++;
        } else {
            wordEntities.push(new WordEntity(words[word], false, null, []));
        }
    }
    return wordEntities;
  }
}
