import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Routes, RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';

import { WorkersComponent } from './workers.component';
import { ImageComponent } from './image.component';
import { ImagesComponent } from './images.component';

import {
  MatButtonModule,
  MatCheckboxModule,
  MatDialogModule,
  MatIconModule,
  MatInputModule,
  MatListModule,
  MatPaginatorModule,
  MatProgressSpinnerModule,
  MatSelectModule,
  MatSliderModule
  } from '@angular/material'

import { PipesModule } from '../pipes/pipes.module'

export const ROUTES: Routes = [
  { path: '', component: WorkersComponent },
  { path: ':id', component: ImagesComponent }
];

@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    MatButtonModule,
    MatCheckboxModule,
    MatDialogModule,
    MatIconModule,
    MatInputModule,
    MatListModule,
    MatPaginatorModule,
    MatProgressSpinnerModule,
    MatSelectModule,
    MatSliderModule,
    PipesModule,
    RouterModule.forChild(ROUTES)
  ],
  declarations: [
    WorkersComponent,
    ImageComponent,
    ImagesComponent,
  ],
  entryComponents: [
    ImageComponent
  ]
})

export class WorkersModule { }
