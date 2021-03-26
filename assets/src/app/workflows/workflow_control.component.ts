
import {
  Component,
  Input,
  EventEmitter,
  Output,
  ViewChild
} from '@angular/core'
import { FormBuilder, FormGroup, FormControl } from '@angular/forms';
import { MatOption } from '@angular/material';

import { WorkflowService } from '../services/workflow.service'

import { WorkflowQueryParams } from '../models/page/workflow_page'

@Component({
  selector: 'workflow-control',
  templateUrl: './workflow_control.component.html',
  styleUrls: ['./workflow_control.component.less'],
})

export class WorkflowControlComponent {
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

  @ViewChild('picker') picker: any;
  @ViewChild('allSelected') private allSelected: MatOption;

  workflowsForm: FormGroup;

  workflows = []

  status = [
    { id: 'completed', label: 'Completed' },
    { id: 'error', label: 'Error' },
    { id: 'processing', label: 'Processing' },
  ]

  constructor(
    private workflowService: WorkflowService,
    private fb: FormBuilder
  ) {
    this.parameters.start_date.setDate(this.parameters.end_date.getDate() - 1);
  }

  ngOnInit() {
    this.workflowsForm = this.fb.group({
      selectedStatus: new FormControl(''),
      selectedWorkflows: new FormControl(''),
      startDate: new FormControl(''),
      endDate: new FormControl(''),
      detailedToogle: new FormControl('')
    });
    this.allSelected.select();

    this.workflowService.getWorkflowIdentifiers("view")
      .subscribe(response => {
        for (var index = 0; index < response.identifiers.length; ++index) {
          this.workflows.push({
            id: response.identifiers[index].identifier,
            label: response.identifiers[index].label
          })
          this.parameters.identifiers.push(
            response.identifiers[index].identifier
          )
        })
  }

  searchWorkflows() {
    this.parametersEvent.emit(this.parameters)
  }

  tosslePerOne(all) {
    if (this.allSelected.selected) {
      this.allSelected.deselect();
      return false;
    }
    if (this.workflowsForm.controls.selectedWorkflows.value.length == this.workflows.length)
      this.allSelected.select();
  }

  toggleAllSelection() {
    if (this.allSelected.selected) {
      this.workflowsForm.controls.selectedWorkflows
        .patchValue([0, ...this.workflows.map(item => item.id)]);
    } else {
      this.workflowsForm.controls.selectedWorkflows.patchValue([]);
    }
  }
}
