import { NgModule } from '@angular/core'
import { CommonModule } from '@angular/common'
import { FormsModule, ReactiveFormsModule } from '@angular/forms'
import { NgxDaterangepickerMd } from 'ngx-daterangepicker-material'

import { MatButtonModule } from '@angular/material/button'
import { MatButtonToggleModule } from '@angular/material/button-toggle'
import { MatCheckboxModule } from '@angular/material/checkbox'
import { MatDatepickerModule } from '@angular/material/datepicker'
import { MatDialogModule } from '@angular/material/dialog'
import { MatExpansionModule } from '@angular/material/expansion'
import { MatIconModule } from '@angular/material/icon'
import { MatInputModule } from '@angular/material/input'
import { MatListModule } from '@angular/material/list'
import { MatSelectModule } from '@angular/material/select'
import { MatSlideToggleModule } from '@angular/material/slide-toggle'

import {
  WorkflowSearchBarComponent,
  WorkflowFiltersManageDialog,
  WorkflowFiltersNameDialog,
} from './workflow-search-bar.component'

@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    MatButtonModule,
    MatButtonToggleModule,
    MatCheckboxModule,
    MatDatepickerModule,
    MatDialogModule,
    MatExpansionModule,
    MatIconModule,
    MatInputModule,
    MatListModule,
    MatSelectModule,
    MatSlideToggleModule,
    NgxDaterangepickerMd.forRoot(),
    ReactiveFormsModule,
  ],
  exports: [WorkflowSearchBarComponent],
  declarations: [
    WorkflowSearchBarComponent,
    WorkflowFiltersManageDialog,
    WorkflowFiltersNameDialog,
  ],
  entryComponents: [WorkflowFiltersManageDialog, WorkflowFiltersNameDialog],
})
export class SearchBarModule {}
