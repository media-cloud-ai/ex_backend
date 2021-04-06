
import {APP_BASE_HREF}    from '@angular/common'
import {
  HttpClientModule,
  HTTP_INTERCEPTORS
} from '@angular/common/http'
import {NgModule}         from '@angular/core'
import {FormsModule, ReactiveFormsModule}      from '@angular/forms'
import {
  BrowserModule,
  Title
} from '@angular/platform-browser'
import {AppComponent}     from './app.component'

import {MatAutocompleteModule} from '@angular/material/autocomplete'
import {MatButtonModule} from '@angular/material/button'
import {MatCardModule} from '@angular/material/card'
import {MatCheckboxModule} from '@angular/material/checkbox'
import {MatChipsModule} from '@angular/material/chips'
import {MatDatepickerModule} from '@angular/material/datepicker';
import {MatDialogModule} from '@angular/material/dialog';
import {MatIconModule} from '@angular/material/icon'
import {MatInputModule} from '@angular/material/input'
import {MatListModule} from '@angular/material/list'
import {MatMenuModule} from '@angular/material/menu'
import {MatPaginatorModule} from '@angular/material/paginator'
import {MatProgressBarModule} from '@angular/material/progress-bar'
import {MatProgressSpinnerModule} from '@angular/material/progress-spinner'
import {MatSelectModule} from '@angular/material/select'
import {MatSidenavModule} from '@angular/material/sidenav'
import {MatSlideToggleModule} from '@angular/material/slide-toggle'
import {MatSliderModule} from '@angular/material/slider'
import {MatSnackBarModule} from '@angular/material/snack-bar'
import {MatTabsModule} from '@angular/material/tabs'
import {MatToolbarModule} from '@angular/material/toolbar'


import {MatStepperModule} from '@angular/material/stepper'
import {NgxMatDatetimePickerModule, NgxMatNativeDateModule} from '@angular-material-components/datetime-picker';
import {BrowserAnimationsModule} from '@angular/platform-browser/animations'

import {
  MomentDateAdapter,
  MatMomentDateModule,
  MAT_MOMENT_DATE_FORMATS
} from '@angular/material-moment-adapter'

import {
  DateAdapter,
  MAT_DATE_LOCALE,
  MAT_DATE_FORMATS
} from '@angular/material/core'

import {RouterModule, Routes}    from '@angular/router'
import {CookieService}           from 'ngx-cookie-service'

import {AppRoutingModule}        from './app-routing.module'
import {SocketModule}            from './socket.module'
import {WorkersModule}            from './workers/workers.module'
import {SearchBarModule}      from './search_bar/search_bar.module'

import {CatalogComponent}        from './catalog/catalog.component'
import {ConfirmComponent}        from './confirm/confirm.component'
import {DashboardComponent}      from './dashboard/dashboard.component'
import {DeclaredWorkersComponent} from './declared_workers/declared_workers.component'
import {DurationComponent}       from './workflows/details/duration.component'
import {IngestComponent}         from './ingest/ingest.component'
import {JobsComponent}           from './jobs/jobs.component'
import {LoginComponent}          from './login/login.component'
import {ParametersComponent}     from './workflows/details/parameters.component'
import {RegisteriesComponent}    from './registeries/registeries.component'
import {RegisteryComponent}      from './registeries/registery.component'
import {RegisteryDetailComponent} from './registeries/registery_detail.component'
import {RightsComponent}         from './users/rights.component'
import {QueuesComponent}         from './amqp/queues.component'
import {StepProgressBarComponent} from './workflows/step_progress_bar.component'
import {StepRendererComponent}   from './workflows/renderer/step_renderer.component'
import {SubtitleComponent}       from './registeries/items/subtitle.component'
import {UserComponent}           from './users/user.component'
import {UsersComponent}          from './users/users.component'
import {WatchersComponent}       from './watchers/watchers.component'
import {WorkflowComponent}       from './workflows/workflow.component'
import {WorkflowDetailsComponent} from './workflows/details/workflow_details.component'
import {WorkflowRendererComponent} from './workflows/renderer/workflow_renderer.component'
import {WorkflowStepDetailsComponent} from './workflows/details/workflow_step_details.component'
import {WorkflowsComponent}      from './workflows/workflows.component'

import {DeleteSubtitleDialog} from './registeries/dialog/delete_subtitle_dialog.component'
import {StartIngestDialog} from './ingest/dialogs/start_ingest.component'
import {JobDetailsDialogComponent} from './jobs/details/job_details_dialog.component'
import {NewSubtitleDialogComponent} from './registeries/dialog/new_subtitle_dialog.component'
import {RdfDialogComponent} from './catalog/rdf/rdf_dialog.component'
import {WorkflowAbortDialogComponent} from './workflows/dialogs/workflow_abort_dialog.component'
import {WorkflowDialogComponent} from './catalog/workflow/workflow_dialog.component'

import {AuthService}             from './authentication/auth.service'
import {AmqpService}             from './services/amqp.service'
import {ApplicationService}      from './services/application.service'
import {CatalogService}          from './services/catalog.service'
import {CredentialService}       from './services/credential.service'
import {DocumentationService}    from './services/documentation.service'
import {DeclaredWorkersService}    from './services/declared_workers.service'
import {IMDbService}             from './services/imdb.service'
import {JobService}              from './services/job.service'
import {MouseMoveService}        from './services/mousemove.service'
import {RdfService}              from './services/rdf.service'
import {RegisteryService}        from './services/registery.service'
import {S3Service}               from './services/s3.service'
import {UserService}             from './services/user.service'
import {WatcherService}          from './services/watcher.service'
import {WorkerService}           from './services/worker.service'
import {WorkflowService}         from './services/workflow.service'

import {GenericModule}           from './generic/generic.module'
import {PipesModule}             from './pipes/pipes.module'

import {TokenInterceptor}        from './authentication/token.interceptor'
import {ErrorInterceptor}        from './authentication/error.interceptor'

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
  exports: [
    RouterModule
  ],
  imports: [
    AppRoutingModule,
    BrowserAnimationsModule,
    BrowserModule,
    GenericModule,
    FormsModule,
    HttpClientModule,
    MatAutocompleteModule,
    MatButtonModule,
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
    CatalogComponent,
    ConfirmComponent,
    DashboardComponent,
    DeclaredWorkersComponent,
    DeleteSubtitleDialog,
    DurationComponent,
    IngestComponent,
    JobsComponent,
    JobDetailsDialogComponent,
    LoginComponent,
    NewSubtitleDialogComponent,
    ParametersComponent,
    QueuesComponent,
    RegisteryComponent,
    RegisteriesComponent,
    RegisteryDetailComponent,
    RightsComponent,
    StartIngestDialog,
    StepProgressBarComponent,
    StepRendererComponent,
    SubtitleComponent,
    UserComponent,
    UsersComponent,
    RdfDialogComponent,
    WatchersComponent,
    WorkflowAbortDialogComponent,
    WorkflowDialogComponent,
    WorkflowComponent,
    WorkflowDetailsComponent,
    WorkflowRendererComponent,
    WorkflowStepDetailsComponent,
    WorkflowsComponent,
  ],
  entryComponents: [
    DeleteSubtitleDialog,
    DurationComponent,
    JobDetailsDialogComponent,
    NewSubtitleDialogComponent,
    ParametersComponent,
    RdfDialogComponent,
    RegisteryComponent,
    RegisteryDetailComponent,
    RightsComponent,
    StartIngestDialog,
    StepProgressBarComponent,
    StepRendererComponent,
    SubtitleComponent,
    UserComponent,
    WatchersComponent,
    WorkflowComponent,
    WorkflowAbortDialogComponent,
    WorkflowDialogComponent,
    WorkflowRendererComponent,
    WorkflowStepDetailsComponent
  ],
  providers: [
    {
      provide: APP_BASE_HREF,
      useValue: '/'
    },
    {
      provide: MAT_DATE_LOCALE,
      useValue: 'fr-FR'
    },
    {
      provide: DateAdapter,
      useClass: MomentDateAdapter,
      deps: [MAT_DATE_LOCALE]
    },
    {
      provide: MAT_DATE_FORMATS,
      useValue: EX_BACKEND_DATE_FORMATS
    },
    {
      provide: HTTP_INTERCEPTORS,
      useClass: TokenInterceptor,
      multi: true
    },
    {
      provide: HTTP_INTERCEPTORS,
      useClass: ErrorInterceptor,
      multi: true
    },
    AmqpService,
    ApplicationService,
    AuthService,
    CatalogService,
    CookieService,
    CredentialService,
    DeclaredWorkersService,
    DocumentationService,
    IMDbService,
    JobService,
    MouseMoveService,
    RdfService,
    RegisteryService,
    S3Service,
    Title,
    UserService,
    WatcherService,
    WorkerService,
    WorkflowService,
  ],
  bootstrap: [
    AppComponent
  ]
})

export class AppModule { }
