import { NgModule } from '@angular/core'
import { CommonModule } from '@angular/common'
import { Routes, RouterModule } from '@angular/router'

import { CredentialComponent } from './credentials/credential.component'
import { CredentialsComponent } from './credentials/credentials.component'
import { JsonEditorDialogComponent } from './notification_templates/dialogs/json_editor_dialog.component'
import { NotificationEndpointsComponent } from './notification_endpoints/notification_endpoints.component'
import { NotificationEndpointComponent } from './notification_endpoints/notification_endpoint.component'
import { NotificationTemplatesComponent } from './notification_templates/notification_templates.component'
import { NotificationTemplateComponent } from './notification_templates/notification_template.component'
import { SecretsComponent } from './secrets.component'

import { FormsModule, ReactiveFormsModule } from '@angular/forms'
import { MatButtonModule } from '@angular/material/button'
import { MatIconModule } from '@angular/material/icon'
import { MatInputModule } from '@angular/material/input'
import { MatSelectModule } from '@angular/material/select'
import { MatTabsModule } from '@angular/material/tabs'
import { AngJsoneditorModule } from '@maaxgr/ang-jsoneditor'

import { PipesModule } from '../pipes/pipes.module'
import { MatDialogModule } from '@angular/material/dialog'

export const ROUTES: Routes = [{ path: '', component: SecretsComponent }]

@NgModule({
  imports: [
    AngJsoneditorModule,
    CommonModule,
    FormsModule,
    MatButtonModule,
    MatDialogModule,
    MatIconModule,
    MatInputModule,
    MatSelectModule,
    MatTabsModule,
    PipesModule,
    ReactiveFormsModule,
    RouterModule.forChild(ROUTES),
  ],
  declarations: [
    CredentialComponent,
    CredentialsComponent,
    JsonEditorDialogComponent,
    NotificationEndpointComponent,
    NotificationEndpointsComponent,
    NotificationTemplatesComponent,
    NotificationTemplateComponent,
    SecretsComponent,
  ],
  entryComponents: [
    CredentialComponent,
    JsonEditorDialogComponent,
    NotificationEndpointComponent,
    NotificationTemplateComponent,
    SecretsComponent,
  ],
})
export class SecretsModule {}
