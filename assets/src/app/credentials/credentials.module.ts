import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Routes, RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';

import {MatButtonModule} from '@angular/material/button';
import {MatIconModule} from '@angular/material/icon';
import {MatInputModule} from '@angular/material/input';
import {MatSelectModule} from '@angular/material/select';

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
