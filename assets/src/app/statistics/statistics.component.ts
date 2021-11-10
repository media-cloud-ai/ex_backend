import { formatDate } from '@angular/common'
import {Component, ViewChild} from '@angular/core'
import {ActivatedRoute, Router} from '@angular/router'

import {StatisticsService} from '../services/statistics.service'
import {WorkflowService} from '../services/workflow.service'
import {DurationStatistics} from '../models/statistics/duration'
import {Workflow} from '../models/workflow'

import { FormBuilder, FormGroup, FormControl } from '@angular/forms';


@Component({
  selector: 'statistics-component',
  templateUrl: 'statistics.component.html',
  styleUrls: ['statistics.component.less']
})
export class StatisticsComponent {

  statistics: []
  workflow_identifiers: Set<string>
  workflow_versions: Set<WorkflowVersion>
  workflow_definitions: Workflow[]
  workflow_durations: Array<WorkflowDurationStatistics>
  workflow_status = [
    { id: 'completed', label: 'Completed' },
    { id: 'error', label: 'Error' },
    { id: 'stopped', label: 'Stopped' },
  ]

  workflowsForm: FormGroup

  selectedIdentifiers: string[] = []
  selectedVersions: WorkflowVersion[] = []
  selectedStatuses = ["completed"]

  start_date: Date
  end_date: Date

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


    this.workflowService.getWorkflowDefinitions().subscribe((definitions) => {
      this.workflow_definitions = definitions.data;
      this.workflow_identifiers = new Set(this.workflow_definitions.map((definition) => definition.identifier).sort());

      let sorted_versions = this.workflow_definitions
          .map((definition) => new WorkflowVersion(definition))
          .sort(WorkflowVersion.compare);
      this.workflow_versions = new Set(sorted_versions);

      this.getStatistics();
    })

    this.workflowsForm.controls.selectedWorkflows.valueChanges.subscribe((change) => {
      if (change.length != this.selectedIdentifiers.length) {
        this.selectedVersions = [];

        let sorted_filtered_versions = this.workflow_definitions
          .filter((definition) => change.includes(definition.identifier))
          .map((definition) => new WorkflowVersion(definition))
          .sort(WorkflowVersion.compare);

        this.workflow_versions = new Set(sorted_filtered_versions);
      }
    });
  }

  private getStatistics() {
    let selected_definitions =
      this.workflow_definitions
        .filter((definition) => this.selectedIdentifiers.length == 0 || this.selectedIdentifiers.includes(definition.identifier))
        .filter((definition) => this.selectedVersions.length == 0 || this.selectedVersions.find(version => {
          let workflow_version = new WorkflowVersion(definition);
          return version.equals(workflow_version);
        }));

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

    let a_version = new WorkflowVersion(a.workflow);
    let b_version = new WorkflowVersion(b.workflow);

    return WorkflowVersion.compare(a_version, b_version);
  }
}

class WorkflowVersion {
  major: number
  minor: number
  micro: number

  constructor(workflow: Workflow) {
    this.major = parseInt(workflow.version_major)
    this.minor = parseInt(workflow.version_minor)
    this.micro = parseInt(workflow.version_micro)
  }

  public equals(other: WorkflowVersion) : boolean {
      return this.major === other.major && this.minor === other.minor && this.minor === other.minor;
  }

  static compare(a: WorkflowVersion, b: WorkflowVersion) {
    let diff = a.major - b.major;
    if (diff != 0) {
      return diff;
    }

    diff = a.minor - b.minor;
    if (diff != 0) {
      return diff;
    }

    diff = a.micro - b.micro;
    if (diff != 0) {
      return diff;
    }

    return 0;
  }

  public toString = () : string => {
      return this.major + "." + this.minor + "." + this.micro;
  }
}
