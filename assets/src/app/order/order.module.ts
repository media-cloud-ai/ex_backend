import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Routes, RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MaterialFileInputModule } from 'ngx-material-file-input';

import { OrdersComponent } from './orders.component';
import { OrderComponent } from './order.component';
import { TranscriptViewerComponent } from './transcript_viewer.component';
import { NlpViewerComponent } from './nlp_viewer.component';
import { EntityComponent } from './entity/entity.component';

import {
  MatButtonModule,
  MatDialogModule,
  MatIconModule,
  MatInputModule,
  MatPaginatorModule,
  MatProgressSpinnerModule,
  MatSelectModule,
  MatSliderModule,
  MatStepperModule,
  MatTabsModule,
  MatTooltipModule,
  MatChipsModule,
  } from '@angular/material'

import {GenericModule} from '../generic/generic.module'
import {PipesModule} from '../pipes/pipes.module'
import {SearchBarModule}      from '../search_bar/search_bar.module'

export const ROUTES: Routes = [
  { path: '', component: OrdersComponent },
  { path: ':id', component: OrderComponent },
  { path: ':id/transcript', component: TranscriptViewerComponent },
  { path: ':id/nlp', component: NlpViewerComponent},
];

@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    GenericModule,
    MatButtonModule,
    MatDialogModule,
    MatIconModule,
    MatInputModule,
    MatPaginatorModule,
    MatProgressBarModule,
    MatProgressSpinnerModule,
    MatSelectModule,
    MatSliderModule,
    MatStepperModule,
    MatTabsModule,
    MaterialFileInputModule,
    PipesModule,
    MatTooltipModule,
    MatChipsModule,
    RouterModule.forChild(ROUTES),
    SearchBarModule
  ],
  declarations: [
    OrderComponent,
    OrdersComponent,
    TranscriptViewerComponent,
    NlpViewerComponent,
    EntityComponent,
  ],
  entryComponents: [
  ]
})

export class OrderModule { }
