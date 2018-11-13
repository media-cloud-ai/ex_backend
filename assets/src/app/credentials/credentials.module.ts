import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Routes, RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';

import {
  MatButtonModule,
  MatIconModule,
  MatInputModule,
  MatSelectModule
  } from '@angular/material'

import { CredentialComponent } from './credential.component';
import { CredentialsComponent } from './credentials.component';

import {PipesModule} from '../pipes/pipes.module'

export const ROUTES: Routes = [
  { path: '', component: CredentialsComponent }
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
    CredentialComponent,
    CredentialsComponent,
  ],
  entryComponents: [
    CredentialComponent,
  ]
})

export class CredentialsModule { }
