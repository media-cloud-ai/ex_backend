import moment = require('moment')
import {
  Component,
  EventEmitter,
  Inject,
  Input,
  Output,
  ViewChild,
} from '@angular/core'
import { FormArray, FormBuilder, FormControl, FormGroup } from '@angular/forms'
import {
  MAT_DIALOG_DATA,
  MatDialog,
  MatDialogRef,
} from '@angular/material/dialog'

import { UserService } from '../services/user.service'
import { WorkflowService } from '../services/workflow.service'
import {
  ViewOption,
  ViewOptionEvent,
  WorkflowQueryParams,
} from '../models/page/workflow_page'

export interface NameDialogData {
  filter_name: string
}

export interface ManageDialogData {
  filters: []
  userService: UserService
}

@Component({
  selector: 'workflow-filters-manage-dialog.component',
  templateUrl: 'workflow-filters-manage-dialog.component.html',
  styleUrls: ['workflow-filters-manage-dialog.component.less'],
})
export class WorkflowFiltersManageDialog {
  constructor(
    public dialogRef: MatDialogRef<WorkflowSearchBarComponent>,
    @Inject(MAT_DIALOG_DATA) public data: ManageDialogData,
  ) {}

  onNoClick(): void {
    this.dialogRef.close()
  }

  deleteFilter(filter_id): void {
    this.data.userService.deleteFilter(filter_id).subscribe(() => {
      this.data.userService.getWorkflowFilters().subscribe((response) => {
        this.data.filters = response
      })
    })
  }
}

@Component({
  selector: 'workflow-filters-name-dialog.component',
  templateUrl: 'workflow-filters-name-dialog.component.html',
  styleUrls: ['workflow-filters-name-dialog.component.less'],
})
export class WorkflowFiltersNameDialog {
  constructor(
    public dialogRef: MatDialogRef<WorkflowSearchBarComponent>,
    @Inject(MAT_DIALOG_DATA) public data: NameDialogData,
  ) {}

  onCancelClick(): void {
    this.dialogRef.close()
  }
}

@Component({
  selector: 'workflow-search-bar',
  templateUrl: './workflow-search-bar.component.html',
  styleUrls: ['./workflow-search-bar.component.less'],
})
export class WorkflowSearchBarComponent {
  @Input() showViewOptionsToolbar = false
  @Input() parameters: WorkflowQueryParams = {
    identifiers: [],
    mode: ['file', 'live'],
    selectedDateRange: {
      startDate: moment(),
      endDate: moment(),
    },
    search: undefined,
    status: ['completed', 'error'],
    headers: [
      'identifier',
      'reference',
      'created_at',
      'duration',
      'launched_by',
    ],
    detailed: false,
    refresh_interval: -1,
    time_interval: 3600,
  }

  @Output() parametersEvent = new EventEmitter<WorkflowQueryParams>()
  @Output() viewOptionsEvent = new EventEmitter<ViewOptionEvent>()

  @ViewChild('picker') picker: any

  ranges: any = {
    Today: [moment().startOf('day'), moment().endOf('day')],
    Yesterday: [
      moment().subtract(1, 'days').startOf('day'),
      moment().subtract(1, 'days').endOf('day'),
    ],
    'Last 7 days': [moment().subtract(6, 'days'), moment()],
    'Last 30 days': [moment().subtract(29, 'days'), moment()],
    'This month': [moment().startOf('month'), moment().endOf('month')],
    'Last month': [
      moment().subtract(1, 'month').startOf('month'),
      moment().subtract(1, 'month').endOf('month'),
    ],
  }
  selectedDateRange: any

  allSelected: boolean
  workflowsForm: FormGroup

  filter_name: ''
  workflow_filters = []
  workflows = []
  status = []

  headers = [
    {
      id: 'identifier',
      label: 'Identifier',
      checked: this.parameters.headers.includes('identifier'),
    },
    {
      id: 'reference',
      label: 'Reference',
      checked: this.parameters.headers.includes('reference'),
    },
    {
      id: 'created_at',
      label: 'Creation date',
      checked: this.parameters.headers.includes('created_at'),
    },
    {
      id: 'duration',
      label: 'Total duration',
      checked: this.parameters.headers.includes('duration'),
    },
    {
      id: 'duration_pending',
      label: 'Pending duration',
      checked: this.parameters.headers.includes('duration_pending'),
    },
    {
      id: 'duration_processing',
      label: 'Processing duration',
      checked: this.parameters.headers.includes('duration_processing'),
    },
    {
      id: 'launched_by',
      label: 'Launched by',
      checked: this.parameters.headers.includes('launched_by'),
    },
    {
      id: 'step_count',
      label: 'Step count',
      checked: this.parameters.headers.includes('step_count'),
    },
  ]

  mode = [
    { id: 'file', label: 'Fichier' },
    { id: 'live', label: 'Live' },
  ]

  refresh_interval = [
    { label: 'Off', value: -1 },
    { label: '1s', value: 1 },
    { label: '5s', value: 5 },
    { label: '10s', value: 10 },
    { label: '30s', value: 30 },
    { label: '1m', value: 60 },
    { label: '5m', value: 300 },
  ]

  constructor(
    private userService: UserService,
    private workflowService: WorkflowService,
    public filtersNameDialog: MatDialog,
    public filtersManageDialog: MatDialog,
  ) {}

  ngOnInit() {
    const today = new Date()
    const yesterday = new Date()
    yesterday.setDate(today.getDate() - 1)

    this.workflowsForm = new FormGroup({
      selectedStatus: new FormControl(''),
      selectedHeaders: new FormArray([]),
      selectedMode: new FormControl(''),
      selectedWorkflows: new FormControl(''),
      selectedPreset: new FormControl(''),
      selectedDateRange: new FormControl({
        startDate: yesterday,
        endDate: today,
      }),
      referenceSearch: new FormControl(''),
      detailedToggle: new FormControl(''),
      liveReloadToggle: new FormControl(''),
      refreshInterval: new FormControl(''),
    })

    const headersFormArray = this.workflowsForm.get(
      'selectedHeaders',
    ) as FormArray

    this.headers.forEach((header) => {
      headersFormArray.push(
        new FormGroup({
          name: new FormControl(header.id),
          checked: new FormControl(this.parameters.headers.includes(header.id)),
        }),
      )
    })

    this.userService.getWorkflowFilters().subscribe((response) => {
      this.workflow_filters = response.sort(this.sortFiltersName)
    })

    this.workflowService
      .getWorkflowStatus()
      .subscribe((response) => (this.status = response.sort()))

    this.allSelected = false

    this.workflowService
      .getWorkflowDefinitions(
        undefined,
        -1,
        'view',
        undefined,
        ['latest'],
        'simple',
      )
      .subscribe((response) => {
        for (let index = 0; index < response.data.length; ++index) {
          this.workflows.push({
            id: response.data[index].identifier,
            label: response.data[index].label,
          })
          this.parameters.identifiers.push(response.data[index].identifier)
        }
        this.toggleAllSelection()
        this.searchWorkflows()
      })
  }

  sortFiltersName(a, b) {
    return a['name'].localeCompare(b['name'])
  }

  searchWorkflows() {
    this.addHeadersSelectionToParameters()
    this.parametersEvent.emit(this.parameters)
  }

  toggleOne() {
    if (this.allSelected) {
      this.allSelected = false
    }
    if (
      this.workflowsForm.controls.selectedWorkflows.value.length ==
      this.workflows.length
    ) {
      this.allSelected = true
    }
  }

  toggleAllSelection() {
    if (!this.allSelected) {
      this.workflowsForm.controls.selectedWorkflows.patchValue([
        0,
        ...this.workflows.map((item) => item.id),
      ])
      this.allSelected = true
    } else {
      this.workflowsForm.controls.selectedWorkflows.patchValue([])
      this.allSelected = false
    }
  }

  toggleDetailed() {
    this.viewOptionsEvent.emit(
      new ViewOptionEvent(ViewOption.Detailed, this.parameters.detailed),
    )
  }

  changeRefreshInterval() {
    this.viewOptionsEvent.emit(
      new ViewOptionEvent(
        ViewOption.RefreshInterval,
        this.parameters.refresh_interval,
      ),
    )
  }

  clearFilters(): void {
    const date = new Date()
    const yesterday = new Date()
    yesterday.setDate(date.getDate() - 1)

    this.parameters = {
      identifiers: [],
      mode: ['file', 'live'],
      selectedDateRange: {
        startDate: yesterday,
        endDate: date,
      },
      search: undefined,
      status: ['completed', 'error'],
      headers: [
        'identifier',
        'reference',
        'created_at',
        'duration',
        'launched_by',
      ],
      detailed: false,
      refresh_interval: -1,
      time_interval: 3600,
    }

    this.workflowsForm.controls.selectedPreset.reset()
    this.setHeadersSelection()

    this.searchWorkflows()
  }

  presetChanged(): void {
    const preset = this.workflowsForm.controls.selectedPreset.value

    this.parameters.identifiers = preset['identifiers']
    this.parameters.mode = preset['mode']
    this.parameters.search =
      preset['search'] != undefined ? preset['search'].toString() : undefined
    this.parameters.status = preset['status']
    this.parameters.headers = preset['headers'] || [
      'identifier',
      'reference',
      'created_at',
      'duration',
      'launched_by',
    ]
    this.setHeadersSelection()
    this.searchWorkflows()
  }

  expandFilters(): void {
    if (document.getElementById('filter-line').classList.contains('expanded')) {
      document.getElementById('filter-line').classList.remove('expanded')
      document.getElementById('expand-icon').classList.remove('expanded')
    } else {
      document.getElementById('filter-line').classList.add('expanded')
      document.getElementById('expand-icon').classList.add('expanded')
    }
  }

  openSaveDialog(): void {
    this.addHeadersSelectionToParameters()

    const dialogRef = this.filtersNameDialog.open(WorkflowFiltersNameDialog, {
      width: '500px',
      data: { filter_name: this.filter_name },
    })

    dialogRef.afterClosed().subscribe((result) => {
      if (result != undefined) {
        this.userService
          .saveWorkflowFilters(result, this.parameters)
          .subscribe(() => {
            this.userService.getWorkflowFilters().subscribe((response) => {
              this.workflow_filters = response.sort(this.sortFiltersName)
            })
            this.filter_name = ''
          })
      }
    })
  }

  openManageDialog(): void {
    const dialogRef = this.filtersManageDialog.open(
      WorkflowFiltersManageDialog,
      {
        width: '500px',
        data: { filters: this.workflow_filters, userService: this.userService },
      },
    )

    dialogRef.afterClosed().subscribe(() => {
      this.userService.getWorkflowFilters().subscribe((response) => {
        this.workflow_filters = response.sort(this.sortFiltersName)
      })
    })
  }

  addHeadersSelectionToParameters(): void {
    const { value } = this.workflowsForm.get('selectedHeaders')
    this.parameters.headers =
      value?.filter((h) => h.checked).map((h) => h.name) || []
  }

  setHeadersSelection(): void {
    const headers = this.workflowsForm.controls?.selectedHeaders['controls']
    headers.forEach((header: FormControl) => {
      header.setValue({
        name: header.value.name,
        checked: this.parameters.headers.includes(header.value.name),
      })
    })
  }
}
