import { formatDate } from '@angular/common'
import {Component, ViewChild} from '@angular/core'
import {ActivatedRoute, Router} from '@angular/router'

import {StatisticsService} from '../services/statistics.service'
import {WorkflowService} from '../services/workflow.service'
import {DurationStatistics} from '../models/statistics/duration'
import {Workflow, Version} from '../models/workflow'

import { FormBuilder, FormGroup, FormControl } from '@angular/forms';


class JobsDurationStatistics {
  name: string
  durations: DurationStatistics
}

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

    let a_version = new Version(a.workflow);
    let b_version = new Version(b.workflow);

    return Version.compare(a_version, b_version);
  }
}


@Component({
  selector: 'statistics-component',
  templateUrl: 'statistics.component.html',
  styleUrls: ['statistics.component.less']
})
export class StatisticsComponent {

  pageSizeOptions = [20, 50, 100];

  // Workflow statistics
  statistics: []
  workflow_identifiers: Set<string>
  workflow_versions: Set<Version>
  workflow_definitions: Workflow[]
  workflow_durations: Array<WorkflowDurationStatistics>
  workflow_status = [
    { id: 'completed', label: 'Completed' },
    { id: 'error', label: 'Error' },
    { id: 'stopped', label: 'Stopped' },
  ]

  workflowsForm: FormGroup

  selectedIdentifiers: string[] = []
  selectedVersions: Version[] = []
  selectedStatuses = ["completed"]

  start_date: Date
  end_date: Date

  workflowStatisticsPage = 0;
  workflowStatisticsPageSize = this.pageSizeOptions[0];
  workflowStatisticsPageTotal: number;

  // Job statistics
  step_names: Set<string>
  job_durations: JobsDurationStatistics[] = []

  jobsForm: FormGroup

  selectedNames: string[] = []

  jobStatisticsPage = 0;
  jobStatisticsPageSize = this.pageSizeOptions[0];
  jobStatisticsPageTotal: number;


  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private statisticsService: StatisticsService,
    private workflowService: WorkflowService,
    private formBuilder: FormBuilder
  ) {
  }

  ngOnInit() {
    this.workflowsForm = this.formBuilder.group({
      selectedWorkflows: new FormControl(''),
      selectedVersion: new FormControl(''),
      selectedStatus: new FormControl(''),
      startDate: new FormControl(''),
      endDate: new FormControl('')
    });

    this.jobsForm = this.formBuilder.group({
      selectedSteps: new FormControl('')
    })

    this.workflowService.getWorkflowDefinitions(undefined, -1, undefined, undefined, undefined, "full_with_steps").subscribe((definitions) => {
      this.workflow_definitions = definitions.data;
      this.workflow_identifiers = new Set(this.workflow_definitions.map((definition) => definition.identifier).sort());
      this.step_names = new Set(this.workflow_definitions.map((definition) => definition.steps).reduce((acc, steps) => acc.concat(steps), []).map((step) => step.name).sort());

      let sorted_versions = this.workflow_definitions
          .map((definition) => new Version(definition))
          .sort(Version.compare);
      this.workflow_versions = new Set(sorted_versions);

      this.getWorkflowStatistics();
      this.getJobStatistics();
    })

    this.workflowsForm.controls.selectedWorkflows.valueChanges.subscribe((change) => {
      if (change.length != this.selectedIdentifiers.length) {
        this.selectedVersions = [];

        let sorted_filtered_versions = this.workflow_definitions
          .filter((definition) => change.includes(definition.identifier))
          .map((definition) => new Version(definition))
          .sort(Version.compare);

        this.workflow_versions = new Set(sorted_filtered_versions);
      }
    });
  }

  private getWorkflowStatistics() {
    let selected_definitions =
      this.workflow_definitions
        .filter((definition) => this.selectedIdentifiers.length == 0 || this.selectedIdentifiers.includes(definition.identifier))
        .filter((definition) => this.selectedVersions.length == 0 || this.selectedVersions.find(version => {
          let workflow_version = new Version(definition);
          return version.equals(workflow_version);
        }))
        .sort(Workflow.compare);

    // Filter with pagination
    let offset = this.workflowStatisticsPage * this.workflowStatisticsPageSize;
    this.workflowStatisticsPageTotal = selected_definitions.length;
    selected_definitions = selected_definitions.slice(offset, offset + this.workflowStatisticsPageSize);

    this.workflow_durations = new Array<WorkflowDurationStatistics>();

    for (let definition of selected_definitions) {
      let params = [
        { "key": "version_major", "value": definition.version_major },
        { "key": "version_minor", "value": definition.version_minor },
        { "key": "version_micro", "value": definition.version_micro },
        { "key": "identifier", "value": definition.identifier },
      ]

      for (let status of this.selectedStatuses) {
        params.push({ "key": "states[]", "value": status });
      }

      if (this.start_date) {
        params.push({ "key": "after_date", "value": formatDate(this.start_date, "yyyy-MM-ddTHH:mm:ss", "fr") });
      }

      if (this.end_date) {
        params.push({ "key": "before_date", "value": formatDate(this.end_date, "yyyy-MM-ddTHH:mm:ss", "fr") });
      }

      this.statisticsService.getWorkflowsDurationStatistics(params).subscribe((statistics) => {
        this.workflow_durations.push(new WorkflowDurationStatistics(definition, statistics));
        this.workflow_durations.sort(WorkflowDurationStatistics.compare);
      })
    }
  }

  private getJobStatistics() {
    let params = []
    for (let name of this.selectedNames) {
      params.push({ "key": "job_type", "value": name });
    }

    this.statisticsService.getJobsDurationStatistics(params).subscribe((statistics) => {
      this.job_durations = statistics;
    });
  }

  private changeWorkflowStatisticsPage(event) {
    this.workflowStatisticsPage = event.pageIndex;
    this.workflowStatisticsPageSize = event.pageSize;
    this.getWorkflowStatistics();
  }

  private changeJobStatisticsPage(event) {
    this.jobStatisticsPage = event.pageIndex;
    this.jobStatisticsPageSize = event.pageSize;
    this.getJobStatistics();
  }
}
