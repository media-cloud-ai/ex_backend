
import {APP_BASE_HREF}    from '@angular/common'
import {
  HttpClientModule,
  HTTP_INTERCEPTORS
} from '@angular/common/http'
import {NgModule}         from '@angular/core'
import {FormsModule}      from '@angular/forms'
import {
  BrowserModule,
  Title
} from '@angular/platform-browser'
import {AppComponent}     from './app.component'
import {
  MatAutocompleteModule,
  MatButtonModule,
  MatCardModule,
  MatCheckboxModule,
  MatDatepickerModule,
  MatDialogModule,
  MatIconModule,
  MatInputModule,
  MatListModule,
  MatMenuModule,
  MatPaginatorModule,
  MatProgressBarModule,
  MatProgressSpinnerModule,
  MatRadioModule,
  MatSelectModule,
  MatSidenavModule,
  MatSliderModule,
  MatSlideToggleModule,
  MatSnackBarModule,
  MatTableModule,
  MatTabsModule,
  MatToolbarModule
  } from '@angular/material'

import {MatStepperModule} from '@angular/material/stepper'
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

import {CatalogComponent}        from './catalog/catalog.component'
import {ConfirmComponent}        from './confirm/confirm.component'
import {DashboardComponent}      from './dashboard/dashboard.component'
import {DurationComponent}       from './workflows/details/duration.component'
import {IngestComponent}         from './ingest/ingest.component'
import {JobsComponent}           from './jobs/jobs.component'
import {LinkImportComponent}     from './persons/link_import.component'
import {LoginComponent}          from './login/login.component'
import {MassiveIngestComponent}  from './massive/massive_ingest.component'
import {ParametersComponent}     from './workflows/details/parameters.component'
import {PersonComponent}         from './persons/person.component'
import {PersonFormComponent}     from './persons/form.component'
import {PersonsComponent}        from './persons/persons.component'
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
import {VideoTitleComponent}     from './workflows/video_title.component'
import {WatchersComponent}       from './watchers/watchers.component'
import {WorkflowComponent}       from './workflows/workflow.component'
import {WorkflowDetailsComponent} from './workflows/details/workflow_details.component'
import {WorkflowRendererComponent} from './workflows/renderer/workflow_renderer.component'
import {WorkflowStepDetailsComponent} from './workflows/details/workflow_step_details.component'
import {WorkflowsComponent}      from './workflows/workflows.component'

import {DeleteSubtitleDialog} from './registeries/dialog/delete_subtitle_dialog.component'
import {StartIngestDialog} from './ingest/dialogs/start_ingest.component'
import {JobDetailsDialogComponent} from './jobs/details/job_details_dialog.component'
import {NewNodeDialogComponent} from './nodes/new_node_dialog.component'
import {NewSubtitleDialogComponent} from './registeries/dialog/new_subtitle_dialog.component'
import {PersonShowDialogComponent} from './persons/show_dialog.component'
import {RdfDialogComponent} from './catalog/rdf/rdf_dialog.component'
import {WorkflowAbortDialogComponent} from './workflows/dialogs/workflow_abort_dialog.component'
import {WorkflowDialogComponent} from './catalog/workflow/workflow_dialog.component'

import {AuthService}             from './authentication/auth.service'
import {AmqpService}             from './services/amqp.service'
import {ApplicationService}      from './services/application.service'
import {CatalogService}          from './services/catalog.service'
import {ContainerService}        from './services/container.service'
import {CredentialService}       from './services/credential.service'
import {DocumentationService}    from './services/documentation.service'
import {ImageService}            from './services/image.service'
import {IMDbService}             from './services/imdb.service'
import {JobService}              from './services/job.service'
import {MouseMoveService}        from './services/mousemove.service'
import {NodeService}             from './services/node.service'
import {PersonService}           from './services/person.service'
import {RdfService}              from './services/rdf.service'
import {RegisteryService}        from './services/registery.service'
import {UserService}             from './services/user.service'
import {WatcherService}          from './services/watcher.service'
import {WorkflowService}         from './services/workflow.service'

import {PipesModule}            from './pipes/pipes.module'

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
    FormsModule,
    HttpClientModule,
    MatAutocompleteModule,
    MatButtonModule,
    MatCardModule,
    MatCheckboxModule,
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
    MatRadioModule,
    MatSelectModule,
    MatSidenavModule,
    MatSliderModule,
    MatSlideToggleModule,
    MatSnackBarModule,
    MatStepperModule,
    MatTableModule,
    MatTabsModule,
    MatToolbarModule,
    PipesModule,
    SocketModule,
    WorkersModule,
  ],
  declarations: [
    AppComponent,
    CatalogComponent,
    ConfirmComponent,
    DashboardComponent,
    DeleteSubtitleDialog,
    DurationComponent,
    IngestComponent,
    JobsComponent,
    JobDetailsDialogComponent,
    LinkImportComponent,
    LoginComponent,
    MassiveIngestComponent,
    NewNodeDialogComponent,
    NewSubtitleDialogComponent,
    ParametersComponent,
    PersonComponent,
    PersonFormComponent,
    PersonShowDialogComponent,
    PersonsComponent,
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
    VideoTitleComponent,
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
    LinkImportComponent,
    NewNodeDialogComponent,
    NewSubtitleDialogComponent,
    ParametersComponent,
    PersonFormComponent,
    PersonShowDialogComponent,
    RdfDialogComponent,
    RegisteryComponent,
    RegisteryDetailComponent,
    RightsComponent,
    StartIngestDialog,
    StepProgressBarComponent,
    StepRendererComponent,
    SubtitleComponent,
    UserComponent,
    VideoTitleComponent,
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
    ContainerService,
    CookieService,
    CredentialService,
    DocumentationService,
    ImageService,
    IMDbService,
    JobService,
    MouseMoveService,
    NodeService,
    PersonService,
    RdfService,
    RegisteryService,
    Title,
    UserService,
    WatcherService,
    WorkflowService,
  ],
  bootstrap: [
    AppComponent
  ]
})

export class AppModule { }
