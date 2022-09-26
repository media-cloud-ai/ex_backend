import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Routes, RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';

import {MatButtonModule} from '@angular/material/button';
import {MatIconModule} from '@angular/material/icon';
import {MatInputModule} from '@angular/material/input';
import {MatSelectModule} from '@angular/material/select';

import { NotificationEndpointComponent } from './notification_endpoint.component';
import { NotificationEndpointsComponent } from './notification_endpoints.component';

import {PipesModule} from '../pipes/pipes.module'

export const ROUTES: Routes = [
  { path: '', component: NotificationEndpointsComponent }
];

@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    MatButtonModule,
    MatIconModule,
    MatInputModule,
    MatSelectModule,
    PipesModule,
    RouterModule.forChild(ROUTES)
  ],
  declarations: [
    NotificationEndpointComponent,
    NotificationEndpointsComponent,
  ],
  entryComponents: [
    NotificationEndpointComponent,
  ]
})

export class NotificationEndpointsModule { }
