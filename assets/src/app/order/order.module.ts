import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Routes, RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { NgxMatFileInputModule } from '@angular-material-components/file-input';

import { OrdersComponent } from './orders.component';
import { OrderComponent } from './order.component';
import { TranscriptViewerComponent } from './transcript_viewer.component';
import { NlpViewerComponent } from './nlp_viewer.component';
import { EntityComponent } from './entity/entity.component';

import {MatButtonModule} from '@angular/material/button';
import {MatDialogModule} from '@angular/material/dialog';
import {MatIconModule} from '@angular/material/icon';
import {MatInputModule} from '@angular/material/input';
import {MatPaginatorModule} from '@angular/material/paginator';
import {MatProgressBarModule} from '@angular/material/progress-bar';
import {MatProgressSpinnerModule} from '@angular/material/progress-spinner';
import {MatSelectModule} from '@angular/material/select';
import {MatSliderModule} from '@angular/material/slider';
import {MatStepperModule} from '@angular/material/stepper';
import {MatTabsModule} from '@angular/material/tabs';
import {MatTooltipModule} from '@angular/material/tooltip';
import {MatChipsModule} from '@angular/material/chips';

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
    NgxMatFileInputModule,
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
