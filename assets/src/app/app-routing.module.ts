import {NgModule} from '@angular/core';
import {
  PreloadAllModules,
  RouterModule,
  Routes
} from '@angular/router';

import {CanDeactivateGuard} from './authentication/can-deactivate-guard.service';
import {AuthGuard} from './authentication/auth-guard.service';
import {AuthService} from './authentication/auth.service';

import {ConfirmComponent} from './confirm/confirm.component';
import {DashboardComponent} from './dashboard/dashboard.component';
import {LoginComponent} from './login/login.component';
import {JobsComponent} from './jobs/jobs.component';
import {PersonComponent} from './persons/person.component';
import {PersonsComponent} from './persons/persons.component';
import {UsersComponent} from './users/users.component';
import {VideosComponent} from './videos/videos.component';
import {WorkflowsComponent} from './workflows/workflows.component';
import {WorkersComponent} from './workers/workers.component';

const appRoutes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  {
    path: 'confirm',
    component: ConfirmComponent
  },
  {
    path: 'login',
    component: LoginComponent
  },
  {
    path: 'dashboard',
    component: DashboardComponent,
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
    path: 'users',
    component: UsersComponent,
    canActivate: [AuthGuard]
  },
  {
    path: 'videos',
    component: VideosComponent,
    canActivate: [AuthGuard]
  },
  {
    path: 'workflows',
    component: WorkflowsComponent,
    canActivate: [AuthGuard]
  },
  {
    path: 'workers',
    component: WorkersComponent,
    canActivate: [AuthGuard]
  },
];

@NgModule({
  imports: [
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
