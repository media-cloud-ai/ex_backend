import {NgModule} from '@angular/core'
import {
  PreloadAllModules,
  RouterModule,
  Routes
} from '@angular/router'
import { BrowserModule } from '@angular/platform-browser';

import {CanDeactivateGuard} from './authentication/can-deactivate-guard.service'
import {AuthGuard} from './authentication/auth-guard.service'
import {AuthService} from './authentication/auth.service'

import {CatalogComponent} from './catalog/catalog.component'
import {ConfirmComponent} from './confirm/confirm.component'
import {DashboardComponent} from './dashboard/dashboard.component'
import {DeclaredWorkersComponent} from './declared_workers/declared_workers.component'
import {IngestComponent} from './ingest/ingest.component'
import {JobsComponent} from './jobs/jobs.component'
import {LoginComponent} from './login/login.component'
import {PersonComponent} from './persons/person.component'
import {PersonsComponent} from './persons/persons.component'
import {RegisteriesComponent} from './registeries/registeries.component'
import {RegisteryDetailComponent} from './registeries/registery_detail.component'
import {UsersComponent} from './users/users.component'
import {WatchersComponent} from './watchers/watchers.component'
import {WorkflowDetailsComponent} from './workflows/details/workflow_details.component'
import {WorkflowsComponent} from './workflows/workflows.component'

import {CredentialsModule} from './credentials/credentials.module'
import {DocumentationModule} from './documentation/documentation.module'
import {OrderModule} from './order/order.module'
import {PlayerModule} from './player/player.module'
import {WorkersModule} from './workers/workers.module'

const appRoutes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  {
    path: 'catalog',
    component: CatalogComponent,
    canActivate: [AuthGuard]
  },  {
    path: 'documentation',
    loadChildren: () => DocumentationModule,
    canActivate: [AuthGuard]
  },
  {
    path: 'confirm',
    component: ConfirmComponent
  },
  {
    path: 'credentials',
    loadChildren: () => CredentialsModule,
    canActivate: [AuthGuard]
  },
  {
    path: 'dashboard',
    component: DashboardComponent,
    canActivate: [AuthGuard]
  },
  {
    path: 'ingest',
    component: IngestComponent,
    canActivate: [AuthGuard]
  },
  {
    path: 'login',
    component: LoginComponent,
    canActivate: [AuthGuard]
  },
  {
    path: 'orders',
    loadChildren: () => OrderModule,
    canActivate: [AuthGuard]
  },
  {
    path: 'people',
    component: PersonsComponent,
    canActivate: [AuthGuard]
  },
  {
    path: 'person',
    component: PersonComponent,
    canActivate: [AuthGuard]
  },
  {
    path: 'player/:id',
    loadChildren: () => PlayerModule,
    canActivate: [AuthGuard]
  },
  {
    path: 'registeries',
    component: RegisteriesComponent,
    canActivate: [AuthGuard]
  },
  {
    path: 'registeries/:id',
    component: RegisteryDetailComponent,
    canActivate: [AuthGuard]
  },
  {
    path: 'users',
    component: UsersComponent,
    canActivate: [AuthGuard]
  },
  {
    path: 'watchers',
    component: WatchersComponent,
    canActivate: [AuthGuard]
  },
  {
    path: 'workers',
    loadChildren: () => WorkersModule,
    canActivate: [AuthGuard]
  },
  {
    path: 'workflows',
    component: WorkflowsComponent,
    canActivate: [AuthGuard]
  },
  {
    path: 'workflows/:id',
    component: WorkflowDetailsComponent,
    canActivate: [AuthGuard]
  },
  {
    path: 'declared-workers',
    component: DeclaredWorkersComponent,
    canActivate: [AuthGuard]
  },
]

@NgModule({
  imports: [
    BrowserModule,
    RouterModule.forRoot(
      appRoutes,
      {
        enableTracing: false,
        preloadingStrategy: PreloadAllModules
      }
    )
  ],
  exports: [
    RouterModule
  ],
  providers: [
    AuthGuard,
    AuthService
  ]
})

export class AppRoutingModule {}
