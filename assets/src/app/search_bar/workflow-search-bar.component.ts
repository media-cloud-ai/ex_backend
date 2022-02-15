
import {
  Component,
  Input,
  EventEmitter,
  Output,
  ViewChild
} from '@angular/core'
import { FormBuilder, FormGroup, FormControl } from '@angular/forms';
import { MatSelectModule } from '@angular/material/select';

import { WorkflowService } from '../services/workflow.service'

import { WorkflowQueryParams } from '../models/page/workflow_page'

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
    start_date: new Date(),
    end_date: new Date(),
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

  allSelected: boolean;
  workflowsForm: FormGroup;

  workflows = []

  status = [
  ]

  mode = [
    { id: 'file', label: 'Fichier' },
    { id: 'live', label: 'Live' },
  ]

  constructor(
    private workflowService: WorkflowService,
    private formBuilder: FormBuilder
  ) {}

  ngOnInit() {
    this.workflowsForm = this.formBuilder.group({
      selectedStatus: new FormControl(''),
      selectedMode: new FormControl(''),
      selectedWorkflows: new FormControl(''),
      startDate: new FormControl(''),
      endDate: new FormControl(''),
      referenceSearch: new FormControl(''),
      detailedToggle: new FormControl('')
    });

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
          this.parameters.identifiers.push(
            response.data[index].identifier
          );
       }
     });
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
}
