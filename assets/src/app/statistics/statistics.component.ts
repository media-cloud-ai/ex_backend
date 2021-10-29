import {Component, ViewChild} from '@angular/core'
import {ActivatedRoute, Router} from '@angular/router'

import {StatisticsService} from '../services/statistics.service'
import {WorkflowService} from '../services/workflow.service'
import {DurationStatistics} from '../models/statistics/duration'
import {Workflow} from '../models/workflow'

class WorkflowDurationStatistics {
  workflow: Workflow
  durations: DurationStatistics

  constructor(workflow: Workflow, durations: DurationStatistics) {
    this.workflow = workflow;
    this.durations = durations;
  }

  static compare(a: WorkflowDurationStatistics, b: WorkflowDurationStatistics) {
    let identifierComparison = a.workflow.identifier.localeCompare(b.workflow.identifier);

    if (identifierComparison != 0) {
      return identifierComparison;
    }

    let a_version =
      parseInt(a.workflow.version_major) * 100 +
      parseInt(a.workflow.version_minor) * 10 +
      parseInt(a.workflow.version_micro)

    let b_version =
      parseInt(a.workflow.version_major) * 100 +
      parseInt(a.workflow.version_minor) * 10 +
      parseInt(a.workflow.version_micro)

    let versionComparison = a_version - b_version;

    if (versionComparison != 0) {
      return versionComparison;
    }

    return 0;
  }
}

@Component({
  selector: 'statistics-component',
  templateUrl: 'statistics.component.html',
  styleUrls: ['statistics.component.less']
})
export class StatisticsComponent {

  statistics: [];
  workflow_durations = new Array<WorkflowDurationStatistics>()

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private statisticsService: StatisticsService,
    private workflowService: WorkflowService
  ) {
  }

  ngOnInit() {
    this.workflowService.getWorkflowDefinitions().subscribe((definitions) => {
      let workflow_definitions = definitions.data;

      for (let definition of workflow_definitions) {
        let params = {
          "version_major": definition.version_major,
          "version_minor": definition.version_minor,
          "version_micro": definition.version_micro,
          "identifier": definition.identifier,
        }

        this.statisticsService.getWorkflowsDurationStatistics(params).subscribe((statistics) => {
          this.workflow_durations.push(new WorkflowDurationStatistics(definition, statistics));
          this.workflow_durations.sort(WorkflowDurationStatistics.compare);
        })
      }
    })
  }
}
