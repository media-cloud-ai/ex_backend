import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import {NgxMatDatetimePickerModule, NgxMatNativeDateModule} from '@angular-material-components/datetime-picker';

import { WorkflowControlComponent } from './workflow_control.component';

import {
  MatButtonModule,
  MatDatepickerModule,
  MatIconModule,
  MatInputModule,
  MatSelectModule,
  MatSlideToggleModule,
  } from '@angular/material'


@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    MatButtonModule,
    MatDatepickerModule,
    MatIconModule,
    MatInputModule,
    MatSelectModule,
    MatSlideToggleModule,
    NgxMatDatetimePickerModule,
    NgxMatNativeDateModule,
    ReactiveFormsModule
  ],
  exports: [
    WorkflowControlComponent
  ],
  declarations: [
    WorkflowControlComponent
  ],
  entryComponents: [
  ]
})

export class SearchBarModule { }
