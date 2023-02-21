import { APP_BASE_HREF } from '@angular/common'
import { HttpClientModule, HTTP_INTERCEPTORS } from '@angular/common/http'
import { NgModule } from '@angular/core'
import { FormsModule, ReactiveFormsModule } from '@angular/forms'
import { BrowserModule, Title } from '@angular/platform-browser'
import { AppComponent } from './app.component'

import { AngJsoneditorModule } from '@maaxgr/ang-jsoneditor'
import { MatAutocompleteModule } from '@angular/material/autocomplete'
import { MatButtonModule } from '@angular/material/button'
import { MatButtonToggleModule } from '@angular/material/button-toggle'
import { MatCardModule } from '@angular/material/card'
import { MatCheckboxModule } from '@angular/material/checkbox'
import { MatChipsModule } from '@angular/material/chips'
import { MatDatepickerModule } from '@angular/material/datepicker'
import { MatDialogModule } from '@angular/material/dialog'
import { MatIconModule } from '@angular/material/icon'
import { MatInputModule } from '@angular/material/input'
import { MatListModule } from '@angular/material/list'
import { MatMenuModule } from '@angular/material/menu'
import { MatPaginatorModule } from '@angular/material/paginator'
import { MatProgressBarModule } from '@angular/material/progress-bar'
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner'
import { MatSelectModule } from '@angular/material/select'
import { MatSidenavModule } from '@angular/material/sidenav'
import { MatSlideToggleModule } from '@angular/material/slide-toggle'
import { MatSliderModule } from '@angular/material/slider'
import { MatSnackBarModule } from '@angular/material/snack-bar'
import { MatTabsModule } from '@angular/material/tabs'
import { MatToolbarModule } from '@angular/material/toolbar'

import { MatStepperModule } from '@angular/material/stepper'
import {
  NgxMatDatetimePickerModule,
  NgxMatNativeDateModule,
} from '@angular-material-components/datetime-picker'
import { BrowserAnimationsModule } from '@angular/platform-browser/animations'
import { NgChartsModule } from 'ng2-charts'
import { ClipboardModule } from '@angular/cdk/clipboard'

import {
  MomentDateAdapter,
  MatMomentDateModule,
} from '@angular/material-moment-adapter'

import {
  DateAdapter,
  MAT_DATE_LOCALE,
  MAT_DATE_FORMATS,
} from '@angular/material/core'

import { RouterModule } from '@angular/router'
import { CookieService } from 'ngx-cookie-service'

import { ChartModule } from 'angular-highcharts'

import { AppRoutingModule } from './app-routing.module'
import { SocketModule } from './socket.module'
import { WorkersModule } from './workers/workers.module'
import { SearchBarModule } from './search_bar/search_bar.module'

import { ConfirmComponent } from './confirm/confirm.component'
import { DashboardComponent } from './dashboard/dashboard.component'
import { DeclaredWorkersComponent } from './declared_workers/declared_workers.component'
import { DurationComponent } from './workflows/details/duration.component'
import { IngestComponent } from './ingest/ingest.component'
import { HelpComponent } from './help/help.component'
import { JobStatisticsComponent } from './statistics/job_statistics.component'
import { JobsComponent } from './jobs/jobs.component'
import { LoginComponent } from './login/login.component'
import { ParametersComponent } from './workflows/details/parameters.component'
import { ResetPasswordComponent } from './reset_password/reset_password.component'
import { RoleComponent } from './users/role.component'
import { QueuesComponent } from './amqp/queues.component'
import { StatisticsComponent } from './statistics/statistics.component'
import { StepProgressBarComponent } from './workflows/step_progress_bar.component'
import { StepRendererComponent } from './workflows/renderer/step_renderer.component'
import { UserComponent } from './users/user.component'
import { UsersComponent } from './users/users.component'
import { WatchersComponent } from './watchers/watchers.component'
import { WorkflowActionsComponent } from './workflows/actions/workflow_actions.component'
import { WorkflowComponent } from './workflows/workflow.component'
import { WorkflowDetailsComponent } from './workflows/details/workflow_details.component'
import { WorkflowRendererComponent } from './workflows/renderer/workflow_renderer.component'
import { WorkflowStatisticsComponent } from './statistics/workflow_statistics.component'
import { WorkflowStepDetailsComponent } from './workflows/details/workflow_step_details.component'
import { WorkflowsComponent } from './workflows/workflows.component'

import { EnterEmailDialogComponent } from './login/dialogs/enter_email_dialog.component'
import { StartIngestDialog } from './ingest/dialogs/start_ingest.component'
import { JobDetailsDialogComponent } from './jobs/details/job_details_dialog.component'
import { RoleOrRightDeletionDialogComponent } from './users/dialogs/role_or_right_deletion_dialog.component'
import { UserEditionDialogComponent } from './users/dialogs/user_edition_dialog.component'
import { UserPasswordEditionDialogComponent } from './users/dialogs/user_password_edition_dialog.component'
import { UserShowCredentialsDialogComponent } from './users/dialogs/user_show_credentials_dialog.component'
import { UserShowValidationLinkDialogComponent } from './users/dialogs/user_show_validation_link_dialog.component'
import { WorkflowActionsDialogComponent } from './workflows/dialogs/workflow_actions_dialog.component'
import { WorkflowPauseDialogComponent } from './workflows/dialogs/workflow_pause_dialog.component'

import { AuthService } from './authentication/auth.service'
import { AmqpService } from './services/amqp.service'
import { ApplicationService } from './services/application.service'
import { CredentialService } from './services/credential.service'
import { DocumentationService } from './services/documentation.service'
import { DeclaredWorkersService } from './services/declared_workers.service'
import { IMDbService } from './services/imdb.service'
import { JobService } from './services/job.service'
import { MouseMoveService } from './services/mousemove.service'
import { NotificationEndpointService } from './services/notification_endpoint.service'
import { NotificationTemplateService } from './services/notification_template.service'
import { StatisticsService } from './services/statistics.service'
import { S3Service } from './services/s3.service'
import { UserService } from './services/user.service'
import { WatcherService } from './services/watcher.service'
import { WorkerService } from './services/worker.service'
import { WorkflowService } from './services/workflow.service'

import { GenericModule } from './generic/generic.module'
import { PipesModule } from './pipes/pipes.module'

import { ErrorInterceptor } from './authentication/error.interceptor'

import 'hammerjs/hammer' // for MatSlideToggleModule

const EX_BACKEND_DATE_FORMATS = {
  parse: {
    dateInput: 'LL',
  },
  display: {
    dateInput: 'LL',
    monthYearLabel: 'MMM YYYY',
    dateA11yLabel: 'LL',
    monthYearA11yLabel: 'MMMM YYYY',
  },
}

@NgModule({
  exports: [RouterModule],
  imports: [
    AngJsoneditorModule,
    AppRoutingModule,
    ClipboardModule,
    BrowserAnimationsModule,
    BrowserModule,
    ChartModule,
    GenericModule,
    FormsModule,
    HttpClientModule,
    MatAutocompleteModule,
    MatButtonModule,
    MatButtonToggleModule,
    MatCardModule,
    MatCheckboxModule,
    MatChipsModule,
    MatDatepickerModule,
    MatDialogModule,
    MatIconModule,
    MatInputModule,
    MatListModule,
    MatMenuModule,
    MatMomentDateModule,
    MatPaginatorModule,
    MatProgressBarModule,
    MatProgressSpinnerModule,
    MatSelectModule,
    MatSidenavModule,
    MatSliderModule,
    MatSlideToggleModule,
    MatSnackBarModule,
    MatStepperModule,
    MatTabsModule,
    MatToolbarModule,
    NgChartsModule,
    NgxMatDatetimePickerModule,
    NgxMatNativeDateModule,
    PipesModule,
    ReactiveFormsModule,
    SearchBarModule,
    SocketModule,
    WorkersModule,
  ],
  declarations: [
    AppComponent,
    ConfirmComponent,
    DashboardComponent,
    DeclaredWorkersComponent,
    DurationComponent,
    EnterEmailDialogComponent,
    HelpComponent,
    IngestComponent,
    JobDetailsDialogComponent,
    JobStatisticsComponent,
    JobsComponent,
    LoginComponent,
    ParametersComponent,
    QueuesComponent,
    ResetPasswordComponent,
    RoleComponent,
    RoleOrRightDeletionDialogComponent,
    StartIngestDialog,
    StatisticsComponent,
    StepProgressBarComponent,
    StepRendererComponent,
    UserComponent,
    UsersComponent,
    UserEditionDialogComponent,
    UserPasswordEditionDialogComponent,
    UserShowCredentialsDialogComponent,
    UserShowValidationLinkDialogComponent,
    WatchersComponent,
    WorkflowActionsComponent,
    WorkflowActionsDialogComponent,
    WorkflowComponent,
    WorkflowDetailsComponent,
    WorkflowPauseDialogComponent,
    WorkflowRendererComponent,
    WorkflowStatisticsComponent,
    WorkflowStepDetailsComponent,
    WorkflowsComponent,
  ],
  entryComponents: [
    DurationComponent,
    EnterEmailDialogComponent,
    JobDetailsDialogComponent,
    JobStatisticsComponent,
    ParametersComponent,
    RoleComponent,
    RoleOrRightDeletionDialogComponent,
    StartIngestDialog,
    StepProgressBarComponent,
    StepRendererComponent,
    UserComponent,
    UserEditionDialogComponent,
    UserPasswordEditionDialogComponent,
    UserShowCredentialsDialogComponent,
    UserShowValidationLinkDialogComponent,
    WatchersComponent,
    WorkflowActionsComponent,
    WorkflowComponent,
    WorkflowActionsDialogComponent,
    WorkflowPauseDialogComponent,
    WorkflowRendererComponent,
    WorkflowStatisticsComponent,
    WorkflowStepDetailsComponent,
  ],
  providers: [
    {
      provide: APP_BASE_HREF,
      useValue: '/',
    },
    {
      provide: MAT_DATE_LOCALE,
      useValue: 'fr-FR',
    },
    {
      provide: DateAdapter,
      useClass: MomentDateAdapter,
      deps: [MAT_DATE_LOCALE],
    },
    {
      provide: MAT_DATE_FORMATS,
      useValue: EX_BACKEND_DATE_FORMATS,
    },
    {
      provide: HTTP_INTERCEPTORS,
      useClass: ErrorInterceptor,
      multi: true,
    },
    AmqpService,
    ApplicationService,
    AuthService,
    CookieService,
    CredentialService,
    DeclaredWorkersService,
    DocumentationService,
    IMDbService,
    JobService,
    MouseMoveService,
    NotificationEndpointService,
    NotificationTemplateService,
    StatisticsService,
    S3Service,
    Title,
    UserService,
    WatcherService,
    WorkerService,
    WorkflowService,
  ],
  bootstrap: [AppComponent],
})
export class AppModule {}
