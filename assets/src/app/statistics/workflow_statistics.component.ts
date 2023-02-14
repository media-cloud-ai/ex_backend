import { formatDate } from '@angular/common'
import { Component, Input } from '@angular/core'
import { FormBuilder, FormGroup, FormControl } from '@angular/forms'

import { DurationStatistics } from '../models/statistics/duration'
import { Workflow, Version } from '../models/workflow'

import { StatisticsService } from '../services/statistics.service'
import { WorkflowService } from '../services/workflow.service'

@Component({
  selector: 'workflow-statistics-component',
  templateUrl: 'workflow_statistics.component.html',
  styleUrls: ['workflow_statistics.component.less'],
})
export class WorkflowStatisticsComponent {
  readonly pageSizeOptions = [10, 20, 50] as const

  @Input() workflows: Workflow[]

  loading = false

  // Workflow statistics
  workflowDurations: Array<WorkflowDurationStatistics>

  // Form filters
  workflowIdentifiers: Set<string>
  workflowVersions: Set<Version>
  workflowStatus = [
    { id: 'completed', label: 'Completed' },
    { id: 'error', label: 'Error' },
    { id: 'stopped', label: 'Stopped' },
  ]

  workflowsForm: FormGroup

  workflowSelectedIdentifiers: string[] = []
  workflowSelectedVersions: Version[] = []
  workflowSelectedStatuses = []

  workflowStartDate: Date
  workflowEndDate: Date

  // Pagination
  workflowStatisticsPage = 0
  workflowStatisticsPageSize = this.pageSizeOptions[0]
  workflowStatisticsPageTotal: number

  constructor(
    private statisticsService: StatisticsService,
    private workflowService: WorkflowService,
    private formBuilder: FormBuilder,
  ) {}

  ngOnInit() {
    this.workflowsForm = this.formBuilder.group({
      selectedWorkflows: new FormControl(''),
      selectedVersion: new FormControl(''),
      selectedStatus: new FormControl(''),
      startDate: new FormControl(''),
      endDate: new FormControl(''),
    })

    this.loading = true

    this.workflowService
      .getWorkflowDefinitions(
        undefined,
        -1,
        undefined,
        undefined,
        undefined,
        'simple',
      )
      .subscribe((definitions) => {
        // Get SimpleWorkflowDefinitions from retrieved and filtered workflow definitions
        this.workflows = definitions.data
          .filter(
            (definition, index, array) =>
              array.findIndex(
                (other_def) =>
                  other_def.identifier == definition.identifier &&
                  other_def.version_major == definition.version_major &&
                  other_def.version_minor == definition.version_minor &&
                  other_def.version_micro == definition.version_micro,
              ) == index,
          )
          .filter(
            (definition) =>
              definition.version_major != undefined &&
              definition.version_minor != undefined &&
              definition.version_micro != undefined,
          )

        this.workflowIdentifiers = new Set(
          this.workflows.map((definition) => definition.identifier).sort(),
        )

        const sorted_versions = this.workflows
          .map((definition) => Version.from_workflow(definition))
          .sort(Version.compare)

        this.workflowVersions = new Set(sorted_versions)

        this.getWorkflowStatistics()
      })

    this.workflowsForm.controls.selectedWorkflows.valueChanges.subscribe(
      (change) => {
        if (change.length != this.workflowSelectedIdentifiers.length) {
          this.workflowSelectedVersions = []

          const sorted_filtered_versions = this.workflows
            .filter((definition) => change.includes(definition.identifier))
            .map((definition) => Version.from_workflow(definition))
            .sort(Version.compare)

          this.workflowVersions = new Set(sorted_filtered_versions)
        }
      },
    )
  }

  getWorkflowStatistics() {
    // Retrieve workflow statistics
    this.loading = true
    this.workflowDurations = new Array<WorkflowDurationStatistics>()

    const selected_identifiers = new Set(
      this.workflows
        .sort(Workflow.compare)
        .map((definition) => definition.identifier)
        .filter((identifier) =>
          this.workflowSelectedIdentifiers.includes(identifier),
        ),
    )

    const params = []
    params.push({ key: 'page', value: this.workflowStatisticsPage })
    params.push({ key: 'size', value: this.workflowStatisticsPageSize })

    for (const identifier of selected_identifiers) {
      params.push({ key: 'workflow_ids[]', value: identifier })
    }

    for (const version of this.workflowSelectedVersions) {
      params.push({ key: 'version[]', value: version })
    }

    for (const status of this.workflowSelectedStatuses) {
      params.push({ key: 'states[]', value: status })
    }

    if (this.workflowStartDate) {
      params.push({
        key: 'after_date',
        value: formatDate(this.workflowStartDate, 'yyyy-MM-ddTHH:mm:ss', 'fr'),
      })
    }

    if (this.workflowEndDate) {
      params.push({
        key: 'before_date',
        value: formatDate(this.workflowEndDate, 'yyyy-MM-ddTHH:mm:ss', 'fr'),
      })
    }

    this.statisticsService
      .getWorkflowsDurationStatistics(params)
      .subscribe((statistics) => {
        //console.log("[WorkflowDurationStatistics] statistics: ", statistics);
        this.loading = false

        this.workflowDurations = statistics.data
          .map(
            (item) =>
              new WorkflowDurationStatistics(
                item.name,
                item.version,
                item.durations,
              ),
          )
          .sort(WorkflowDurationStatistics.compare)
        this.workflowStatisticsPageTotal = statistics.total
      })
  }

  changeWorkflowStatisticsPage(event) {
    this.workflowStatisticsPage = event.pageIndex
    this.workflowStatisticsPageSize = event.pageSize
    this.getWorkflowStatistics()
  }
}

class WorkflowDurationStatistics {
  identifier: string
  version: Version
  durations: DurationStatistics

  constructor(
    identifier: string,
    version: string,
    durations: DurationStatistics,
  ) {
    this.identifier = identifier
    this.version = Version.from_string(version)
    this.durations = durations
  }

  static compare(a: WorkflowDurationStatistics, b: WorkflowDurationStatistics) {
    const identifierComparison = a.identifier.localeCompare(b.identifier)

    if (identifierComparison != 0) {
      return identifierComparison
    }

    return Version.compare(a.version, b.version)
  }
}
