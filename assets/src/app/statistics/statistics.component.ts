import {Component} from '@angular/core'

import {Workflow} from '../models/workflow'

import {StatisticsService} from '../services/statistics.service'
import {WorkflowService} from '../services/workflow.service'

@Component({
  selector: 'statistics-component',
  templateUrl: 'statistics.component.html',
  styleUrls: ['statistics.component.less']
})
export class StatisticsComponent {

  workflows: Workflow[]

  constructor(
    private statisticsService: StatisticsService,
    private workflowService: WorkflowService,
  ) {
  }

  ngOnInit() {

    this.workflowService.getWorkflowDefinitions(undefined, -1, undefined, undefined, undefined, "simple")
      .subscribe((definitions) => {
        // Get all workflow definitions and filter duplicated
        this.workflows = definitions.data
          .filter((definition, index, array) =>
            array.findIndex((other_def) =>
              other_def.identifier == definition.identifier &&
              other_def.version_major == definition.version_major &&
              other_def.version_minor == definition.version_minor &&
              other_def.version_micro == definition.version_micro
              ) == index
            )
          .filter((definition) =>
            definition.version_major != undefined &&
            definition.version_minor != undefined &&
            definition.version_micro != undefined
            );
      })
  }

}
