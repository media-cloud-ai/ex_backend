
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
    start_date: new Date(),
    end_date: new Date(),
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
  @ViewChild('allSelected') private allSelected: boolean = true;

  workflowsForm: FormGroup;

  workflows = []

  status = [
    { id: 'completed', label: 'Completed' },
    { id: 'error', label: 'Error' },
    { id: 'pending', label: 'Pending' },
    { id: 'processing', label: 'Processing' },
  ]

  constructor(
    private workflowService: WorkflowService,
    private formBuilder: FormBuilder
  ) {}

  ngOnInit() {
    this.workflowsForm = this.formBuilder.group({
      selectedStatus: new FormControl(''),
      selectedWorkflows: new FormControl(''),
      startDate: new FormControl(''),
      endDate: new FormControl(''),
      detailedToogle: new FormControl('')
    });

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

  tosslePerOne(all) {
    if (this.allSelected) {
      this.allSelected = false;
      return false;
    }
    if (this.workflowsForm.controls.selectedWorkflows.value.length == this.workflows.length)
      this.allSelected = true;
  }

  toggleAllSelection() {
    if (this.allSelected) {
      this.workflowsForm.controls.selectedWorkflows
        .patchValue([0, ...this.workflows.map(item => item.id)]);
    } else {
      this.workflowsForm.controls.selectedWorkflows.patchValue([]);
    }
  }

  toogleDetailed() {
    this.detailedEvent.emit(this.parameters.detailed)
  }
}
