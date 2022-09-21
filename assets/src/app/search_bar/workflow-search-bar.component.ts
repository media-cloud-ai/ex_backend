
import moment = require('moment');

import {
  Component,
  Input,
  EventEmitter,
  Output,
  ViewChild,
  Inject
} from '@angular/core'
import { FormBuilder, FormGroup, FormControl } from '@angular/forms';
import { MatDialog, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';


import { UserService } from '../services/user.service';
import { WorkflowService } from '../services/workflow.service'
import { WorkflowQueryParams } from '../models/page/workflow_page'


export interface NameDialogData {
  filter_name: string
}

export interface ManageDialogData {
  filters: {},
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
    @Inject(MAT_DIALOG_DATA) public data: ManageDialogData
  ) {}

  onNoClick(): void {
    this.dialogRef.close();
  }

  deleteFilter(filter_id): void {
    this.data.userService.deleteFilter(filter_id).subscribe(() => {
      this.data.userService.getWorkflowFilters()
        .subscribe(response => {
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
    @Inject(MAT_DIALOG_DATA) public data: NameDialogData
  ) {}

  onCancelClick(): void {
    this.dialogRef.close();
  }

}

@Component({
  selector: 'workflow-search-bar',
  templateUrl: './workflow-search-bar.component.html',
  styleUrls: ['./workflow-search-bar.component.less'],
})

export class WorkflowSearchBarComponent {
  @Input() showDetailedToggle: boolean = false;
  @Input() parameters: WorkflowQueryParams = {
    identifiers: [],
    mode: [
       "file",
       "live"
    ],
    selectedDateRange: {
      startDate: moment(),
      endDate: moment(),
    },
    search: undefined,
    status: [
      "completed",
      "error"
    ],
    detailed: false,
    time_interval: 3600
  };

  @Output() parametersEvent = new EventEmitter<WorkflowQueryParams>();
  @Output() detailedEvent = new EventEmitter<boolean>();

  @ViewChild('picker') picker: any;

  ranges: any = {
    'Today': [moment().startOf('day'), moment()],
    'Yesterday': [moment().subtract(1, 'days').startOf('day'), moment().subtract(1, 'days').endOf('day')],
    'Last 7 days': [moment().subtract(6, 'days'), moment()],
    'Last 30 days': [moment().subtract(29, 'days'), moment()],
    'This month': [moment().startOf('month'), moment().endOf('month')],
    'Last month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
  };
  selectedDateRange: any;

  allSelected: boolean;
  workflowsForm: FormGroup;

  filter_name: "";
  workflow_filters = [];
  workflows = [];
  status = [];

  mode = [
    { id: 'file', label: 'Fichier' },
    { id: 'live', label: 'Live' },
  ];

  constructor(
    private userService: UserService,
    private workflowService: WorkflowService,
    private formBuilder: FormBuilder,
    public filtersNameDialog: MatDialog,
    public filtersManageDialog: MatDialog
  ) {}

  ngOnInit() {
    let today = new Date()
    let yesterday = new Date()
    yesterday.setDate(today.getDate() - 1)

    this.workflowsForm = this.formBuilder.group({
      selectedStatus: new FormControl(''),
      selectedMode: new FormControl(''),
      selectedWorkflows: new FormControl(''),
      selectedPreset:  new FormControl(''),
      selectedDateRange: {
        startDate: yesterday,
        endDate: today
      },
      referenceSearch: new FormControl(''),
      detailedToggle: new FormControl('')
    });

    this.userService.getWorkflowFilters()
      .subscribe(response => {
        this.workflow_filters = response.sort(this.sortFiltersName)
      })

    this.workflowService.getWorkflowStatus()
      .subscribe(response => this.status = response.sort());

    this.allSelected = false;

    this.workflowService.getWorkflowDefinitions(undefined, -1, "view", undefined, ["latest"], "simple")
      .subscribe(response => {
        for (var index = 0; index < response.data.length; ++index) {
          this.workflows.push({
            id: response.data[index].identifier,
            label: response.data[index].label
          });
        }
        this.toggleAllSelection();
     });

  }

  sortFiltersName(a, b) {
    return a["name"].localeCompare(b["name"]);
  }

  searchWorkflows() {
    this.parametersEvent.emit(this.parameters)
  }

  toggleOne() {
    if (this.allSelected) {
      this.allSelected = false;
    }
    if (this.workflowsForm.controls.selectedWorkflows.value.length == this.workflows.length) {
      this.allSelected = true;
    }
  }

  toggleAllSelection() {
    if (!this.allSelected) {
      this.workflowsForm.controls.selectedWorkflows
        .patchValue([0, ...this.workflows.map(item => item.id)]);
      this.allSelected = true;
    } else {
      this.workflowsForm.controls.selectedWorkflows.patchValue([]);
      this.allSelected = false;
    }
  }

  toggleDetailed() {
    this.detailedEvent.emit(this.parameters.detailed)
  }

  clearFilters(): void {
    let date = new Date()
    let yesterday = new Date()
    yesterday.setDate(date.getDate() - 1)

    this.parameters = {
      identifiers: [],
      mode: [
         "file",
         "live"
      ],
      selectedDateRange: {
        startDate: yesterday,
        endDate: date,
      },
      search: undefined,
      status: [
        "completed",
        "error"
      ],
      detailed: false,
      time_interval: 3600
    };

    this.workflowsForm.controls.selectedPreset.setValue("")

    this.searchWorkflows()
  }

  presetChanged(): void {
    let preset = this.workflowsForm.controls.selectedPreset.value
    this.parameters.identifiers = preset["identifiers"]
    this.parameters.mode = preset["mode"]
    this.parameters.search = preset["search"] != undefined ? preset["search"].toString() : undefined
    this.parameters.status = preset["status"]
    this.searchWorkflows()
  }

  expandFilters(): void {
    if (document.getElementById("filter-line").classList.contains("expanded")) {
      document.getElementById("filter-line").classList.remove("expanded")
      document.getElementById("expand-icon").classList.remove("expanded")
    } else {
      document.getElementById("filter-line").classList.add("expanded")
      document.getElementById("expand-icon").classList.add("expanded")
    }
  }

  openSaveDialog(): void {
    const dialogRef = this.filtersNameDialog.open(WorkflowFiltersNameDialog, {
      width: '500px',
      data: {filter_name: this.filter_name}
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result != undefined) {
        this.userService.saveWorkflowFilters(result, this.parameters).subscribe(() => {
          this.userService.getWorkflowFilters().subscribe(response => {
            this.workflow_filters = response.sort(this.sortFiltersName)
          })
          this.filter_name = ""
        })
      }
    })
  }

  openManageDialog(): void {
    const dialogRef = this.filtersManageDialog.open(WorkflowFiltersManageDialog, {
      width: '500px',
      data: {filters: this.workflow_filters, userService: this.userService}
    });

    dialogRef.afterClosed().subscribe(() => {
      this.userService.getWorkflowFilters().subscribe(response => {
        this.workflow_filters = response.sort(this.sortFiltersName)
      })
    })
  }
}
