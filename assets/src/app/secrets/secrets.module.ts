import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Routes, RouterModule } from '@angular/router';
import { MatTabsModule } from '@angular/material/tabs';
import {PipesModule} from '../pipes/pipes.module';
import {SecretsComponent} from './secrets.component';
import { NotificationEndpointsComponent } from './notification_endpoints/notification_endpoints.component';
import { NotificationEndpointComponent } from './notification_endpoints/notification_endpoint.component';
import { CredentialComponent } from './credentials/credential.component';
import { CredentialsComponent } from './credentials/credentials.component';
import { FormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';

export const ROUTES: Routes = [
  {path: '', component : SecretsComponent},
];

@NgModule({
  imports: [
    CommonModule,
    PipesModule,
    FormsModule,
    MatButtonModule,
    MatIconModule,
    MatInputModule,
    MatSelectModule,
    MatTabsModule,
    PipesModule,
    RouterModule.forChild(ROUTES)
  ],
  declarations: [
    SecretsComponent,
    CredentialComponent,
    CredentialsComponent,
    NotificationEndpointComponent,
    NotificationEndpointsComponent
  ],
  entryComponents: [
    SecretsComponent,
    CredentialComponent,
    NotificationEndpointComponent
  ]
})

export class SecretsModule { }
