import {formatDate} from '@angular/common'
import {Component, Input} from '@angular/core'
import {FormBuilder, FormGroup, FormControl} from '@angular/forms';
import {MatChipInputEvent} from '@angular/material/chips';

import {JobDurationStatisticsEntry} from '../models/statistics/duration'
import {Workflow, Version} from '../models/workflow'

import {StatisticsService} from '../services/statistics.service'
import {WorkflowService} from '../services/workflow.service'



@Component({
  selector: 'job-statistics-component',
  templateUrl: 'job_statistics.component.html',
  styleUrls: ['job_statistics.component.less']
})
export class JobStatisticsComponent {

  readonly pageSizeOptions = [10, 20, 50] as const;

  @Input() workflows: Workflow[]

  loading = false;

  // Job statistics
  stepNames: Set<string>
  jobDurations: Array<JobDurationStatisticsEntry> = []
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
    private statisticsService: StatisticsService,
    private workflowService: WorkflowService,
    private formBuilder: FormBuilder
  ) {
  }

  ngOnInit() {

    this.jobsForm = this.formBuilder.group({
      selectedSteps: new FormControl(''),
      selectedStatus: new FormControl(''),
      startDate: new FormControl(''),
      endDate: new FormControl('')
    })

    this.loading = true;

    // Get step names to retrieve jobs statistics
    let step_names = [];
    let versions_per_identifier = new Map<string, string[]>();

    for (let workflow of this.workflows) {
      if (versions_per_identifier.has(workflow.identifier)) {
        continue;
      }

      let versions =
        this.workflows
          .filter((definition) => definition.identifier == workflow.identifier)
          .map((definition) => Version.from_workflow(definition).toString());

      versions_per_identifier.set(workflow.identifier, versions);
    }

    for (let [identifier, versions] of versions_per_identifier) {
      this.workflowService.getWorkflowDefinitions(undefined, -1, undefined, identifier, versions, "full_with_steps")
        .subscribe((definitions) => {
          step_names =
            step_names.concat(
              definitions.data
                .map((definition) => definition.steps)
                .reduce((acc, steps) => acc.concat(steps), [])
                .map((step) => step.name)
              );

          this.stepNames = new Set(step_names.sort());
        });
    }

    this.getJobStatistics();
  }

  private getJobStatistics() {

    this.loading = true;

    let params = []

    params.push({ "key": "page", "value": this.jobStatisticsPage });
    params.push({ "key": "size", "value": this.jobStatisticsPageSize });

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

    this.statisticsService.getJobDurationStatistics(params)
      .subscribe((statistics) => {
        // console.log("[JobDurationStatistics] statistics: ", statistics);
        this.loading = false;

        this.jobDurations = statistics.data;
        this.jobStatisticsPageTotal = statistics.total;
      });
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
