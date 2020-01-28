
import {Component} from '@angular/core'
import {ActivatedRoute} from '@angular/router'
import { HttpClient } from '@angular/common/http';

import {S3Service} from '../services/s3.service'
import {WorkflowService} from '../services/workflow.service'
import {WorkflowPage} from '../models/page/workflow_page'
import {Workflow} from '../models/workflow'
import {NlpEntity} from '../models/nlp_entity'

@Component({
  selector: 'nlp-viewer-component',
  templateUrl: 'nlp_viewer.component.html',
  styleUrls: ['./nlp_viewer.component.less'],
})

export class NlpViewerComponent {
  workflow_id: number;
  workflow: Workflow;
  nlp: any;
  words: NlpEntity[];

  constructor(
    private http: HttpClient,
    private route: ActivatedRoute,
    private workflowService: WorkflowService,
    private s3Service: S3Service,
  ) {}

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
                  this.http.get(response.url).subscribe(content => {
                    this.nlp = content
                    this.words = this.getListOfWord(this.nlp.words_list);
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

  createListOfWords(){
    var words_list = this.nlp.words_list;
    var words = [];
    for (let word_elem of words_list){
      var word = new NlpEntity;
      word.token = word_elem;
      words.push(word);
    }
    return words;
  }

  getListOfWord(text: string[]){
    var entities = this.nlp.entity;
    var len_entities = entities.length;
    var i_entity = 0;
    var id_ner = 0;

    var words = this.createListOfWords();
    
    for (var i_word = 0; i_word < words.length; i_word++){
      if (i_entity < len_entities && entities[i_entity].list_id[0] <= i_word){
        id_ner = i_word;
        for(var i_listid = 0; i_listid < entities[i_entity].list_id.length; i_listid++){
          words[i_word].ner = true;
          words[i_word].id_ner = id_ner;
          words[i_word].token = entities[i_entity].string_ner;
          words[i_word].type = entities[i_entity].type;
          words[i_word].relevance_score = entities[i_entity].relevance_score;
        }
        i_entity++;
      }
    }
    return words;
  }
}