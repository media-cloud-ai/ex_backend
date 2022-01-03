import { formatDate } from '@angular/common'
import {Component, ViewChild} from '@angular/core'
import {ActivatedRoute, Router} from '@angular/router'
import {MatChipInputEvent} from '@angular/material/chips';
import {COMMA, ENTER} from '@angular/cdk/keycodes';

import {StatisticsService} from '../services/statistics.service'
import {WorkflowService} from '../services/workflow.service'
import {DurationStatistics, JobsDurationStatistics} from '../models/statistics/duration'
import {Workflow, Version} from '../models/workflow'

import { FormBuilder, FormGroup, FormControl } from '@angular/forms';

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

  readonly pageSizeOptions = [20, 50, 100] as const;
  readonly separatorKeysCodes = [ENTER, COMMA] as const;

  // Workflow statistics
  statistics: []
  workflowIdentifiers: Set<string>
  workflowVersions: Set<Version>
  workflowDefinitions: Workflow[]
  workflowDurations: Array<WorkflowDurationStatistics>
  workflowStatus = [
    { id: 'completed', label: 'Completed' },
    { id: 'error', label: 'Error' },
    { id: 'stopped', label: 'Stopped' },
  ]

  workflowsForm: FormGroup

  workflowSelectedIdentifiers: string[] = []
  workflowSelectedVersions: Version[] = []
  workflowSelectedStatuses = ["completed"]

  workflowStartDate: Date
  workflowEndDate: Date

  workflowStatisticsPage = 0;
  workflowStatisticsPageSize = this.pageSizeOptions[0];
  workflowStatisticsPageTotal: number;

  // Job statistics
  stepNames: Set<string>
  jobDurations: Array<JobsDurationStatistics> = []
  jobStatus = [
    { id: 'queued', label: 'Queued' },
    { id: 'ready_to_init', label: 'Ready to init' },
    { id: 'ready_to_start', label: 'Ready to start' },
    { id: 'initializing', label: 'Initializing' },
    { id: 'initialized', label: 'Initialized' },
    { id: 'starting', label: 'Starting' },
    { id: 'processing', label: 'Processing' },
    { id: 'running', label: 'Running' },
    { id: 'update', label: 'Update' },
    { id: 'updating', label: 'Updating' },
    { id: 'skipped', label: 'Skipped' },
    { id: 'stopped', label: 'Stopped' },
    { id: 'completed', label: 'Completed' },
    { id: 'error', label: 'Error' },
    { id: 'retrying', label: 'Retrying' },
    { id: 'unknown', label: 'Unknown' }
  ]

  jobInstanceIDs: string[] = []
  jobWorkerLabels: string[] = []
  jobWorkerVersions: string[] = []

  jobsForm: FormGroup

  jobSelectedNames: string[] = []

  jobSelectedStatus = ["completed"]

  jobStartDate: Date
  jobEndDate: Date

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
      selectedSteps: new FormControl(''),
      selectedStatus: new FormControl(''),
      startDate: new FormControl(''),
      endDate: new FormControl('')
    })

    this.workflowService.getWorkflowDefinitions(undefined, -1, undefined, undefined, undefined, "full_with_steps").subscribe((definitions) => {
      this.workflowDefinitions = definitions.data;
      this.workflowIdentifiers = new Set(this.workflowDefinitions.map((definition) => definition.identifier).sort());
      this.stepNames = new Set(this.workflowDefinitions.map((definition) => definition.steps).reduce((acc, steps) => acc.concat(steps), []).map((step) => step.name).sort());

      let sorted_versions = this.workflowDefinitions
          .map((definition) => new Version(definition))
          .sort(Version.compare);
      this.workflowVersions = new Set(sorted_versions);

      this.getWorkflowStatistics();
      this.getJobStatistics();

    })

    this.workflowsForm.controls.selectedWorkflows.valueChanges.subscribe((change) => {
      if (change.length != this.workflowSelectedIdentifiers.length) {
        this.workflowSelectedVersions = [];

        let sorted_filtered_versions = this.workflowDefinitions
          .filter((definition) => change.includes(definition.identifier))
          .map((definition) => new Version(definition))
          .sort(Version.compare);

        this.workflowVersions = new Set(sorted_filtered_versions);
      }
    });
  }

  private getWorkflowStatistics() {
    let selected_definitions =
      this.workflowDefinitions
        .filter((definition) => this.workflowSelectedIdentifiers.length == 0 || this.workflowSelectedIdentifiers.includes(definition.identifier))
        .filter((definition) => this.workflowSelectedVersions.length == 0 || this.workflowSelectedVersions.find(version => {
          let workflowVersion = new Version(definition);
          return version.equals(workflowVersion);
        }))
        .sort(Workflow.compare);

    // Filter with pagination
    let offset = this.workflowStatisticsPage * this.workflowStatisticsPageSize;
    this.workflowStatisticsPageTotal = selected_definitions.length;
    selected_definitions = selected_definitions.slice(offset, offset + this.workflowStatisticsPageSize);

    this.workflowDurations = new Array<WorkflowDurationStatistics>();

    for (let definition of selected_definitions) {
      let params = [
        { "key": "version_major", "value": definition.version_major },
        { "key": "version_minor", "value": definition.version_minor },
        { "key": "version_micro", "value": definition.version_micro },
        { "key": "identifier", "value": definition.identifier },
      ]

      for (let status of this.workflowSelectedStatuses) {
        params.push({ "key": "states[]", "value": status });
      }

      if (this.workflowStartDate) {
        params.push({ "key": "after_date", "value": formatDate(this.workflowStartDate, "yyyy-MM-ddTHH:mm:ss", "fr") });
      }

      if (this.workflowEndDate) {
        params.push({ "key": "before_date", "value": formatDate(this.workflowEndDate, "yyyy-MM-ddTHH:mm:ss", "fr") });
      }

      this.statisticsService.getWorkflowsDurationStatistics(params).subscribe((statistics) => {
        this.workflowDurations.push(new WorkflowDurationStatistics(definition, statistics));
        this.workflowDurations.sort(WorkflowDurationStatistics.compare);
      })
    }
  }

  private getJobStatistics() {
    let params = []
    for (let name of this.jobSelectedNames) {
      params.push({ "key": "job_type", "value": name });
    }

    for (let status of this.jobSelectedStatus) {
      params.push({ "key": "states[]", "value": status });
    }

    for (let instanceId of this.jobInstanceIDs) {
      params.push({ "key": "instance_ids[]", "value": instanceId });
    }

    for (let workerLabel of this.jobWorkerLabels) {
      params.push({ "key": "labels[]", "value": workerLabel });
    }

    for (let workerVersion of this.jobWorkerVersions) {
      params.push({ "key": "versions[]", "value": workerVersion });
    }

    if (this.jobStartDate) {
      params.push({ "key": "after_date", "value": formatDate(this.jobStartDate, "yyyy-MM-ddTHH:mm:ss", "fr") });
    }

    if (this.jobEndDate) {
      params.push({ "key": "before_date", "value": formatDate(this.jobEndDate, "yyyy-MM-ddTHH:mm:ss", "fr") });
    }

    this.statisticsService.getJobsDurationStatistics(params).subscribe((statistics) => {
      this.jobDurations = statistics;
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

  private removeChip(list: string[], instance_id: string) {
    const index = list.indexOf(instance_id);

    if (index >= 0) {
      list.splice(index, 1);
    }
  }

  private addChip(list: string[], event: MatChipInputEvent) {
    const value = (event.value || '').trim();

    if (value) {
      list.push(value);
    }

    if (event.input) {
      event.input.value = '';
    }
  }
}
