import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Routes, RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';

import { OrdersComponent } from './orders.component';
import { OrderComponent } from './order.component';

import {
  MatButtonModule,
  MatDialogModule,
  MatIconModule,
  MatInputModule,
  MatProgressSpinnerModule,
  MatSelectModule,
  MatSliderModule
  } from '@angular/material'

import {PipesModule} from '../pipes/pipes.module'

export const ROUTES: Routes = [
  { path: '', component: OrdersComponent },
  { path: ':id', component: OrderComponent }
];

@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    MatButtonModule,
    MatDialogModule,
    MatIconModule,
    MatInputModule,
    MatProgressSpinnerModule,
    MatSelectModule,
    MatSliderModule,
    PipesModule,
    RouterModule.forChild(ROUTES)
  ],
  declarations: [
    OrderComponent,
    OrdersComponent,
  ],
  entryComponents: [
  ]
})

export class OrderModule { }
