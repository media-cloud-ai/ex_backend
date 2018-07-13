
import {APP_BASE_HREF}    from '@angular/common';
import {
  HttpClientModule,
  HTTP_INTERCEPTORS
} from '@angular/common/http';
import {NgModule}         from '@angular/core';
import {FormsModule}      from '@angular/forms';
import {
  BrowserModule,
  Title
} from '@angular/platform-browser';
import {AppComponent}     from './app.component';
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
  MatProgressSpinnerModule,
  MatRadioModule,
  MatSelectModule,
  MatSidenavModule,
  MatSlideToggleModule,
  MatTableModule,
  MatToolbarModule
  } from '@angular/material';

import {MatStepperModule} from '@angular/material/stepper';
import {BrowserAnimationsModule} from '@angular/platform-browser/animations';

import {
  MomentDateAdapter,
  MatMomentDateModule,
  MAT_MOMENT_DATE_FORMATS
} from '@angular/material-moment-adapter';

import {
  DateAdapter,
  MAT_DATE_LOCALE,
  MAT_DATE_FORMATS
} from '@angular/material/core';

import {RouterModule, Routes}    from '@angular/router';
import {CookieService}           from 'ngx-cookie-service';

import {AppRoutingModule}        from './app-routing.module';
import {SocketModule}            from './socket.module';

import {CatalogComponent}         from './catalog/catalog.component';
import {ConfirmComponent}        from './confirm/confirm.component';
import {DashboardComponent}      from './dashboard/dashboard.component';
import {DurationComponent}       from './workflows/details/duration.component';
import {IngestComponent}           from './ingest/ingest.component';
import {JobsComponent}           from './jobs/jobs.component';
import {LinkImportComponent}     from './persons/link_import.component';
import {LoginComponent}          from './login/login.component';
import {ParametersComponent}     from './workflows/details/parameters.component';
import {PersonComponent}         from './persons/person.component';
import {PersonFormComponent}     from './persons/form.component';
import {PersonsComponent}        from './persons/persons.component';
import {RightsComponent}         from './users/rights.component';
import {QueuesComponent}         from './amqp/queues.component';
import {StepProgressBarComponent} from './workflows/step_progress_bar.component';
import {UsersComponent}          from './users/users.component';
import {VideoTitleComponent}     from './workflows/video_title.component';
import {WatchersComponent}       from './watchers/watchers.component';
import {WorkflowComponent}       from './workflows/workflow.component';
import {WorkflowDetailsComponent}     from './workflows/details/workflow_details.component';
import {WorkflowStepDetailsComponent} from './workflows/details/workflow_step_details.component';
import {WorkflowsComponent}      from './workflows/workflows.component';
import {WorkersComponent}        from './workers/workers.component';

import {JobDetailsDialogComponent}    from './jobs/details/job_details_dialog.component';
import {PersonShowDialogComponent} from './persons/show_dialog.component';
import {RdfDialogComponent}      from './catalog/rdf/rdf_dialog.component';
import {WorkflowAbortDialogComponent} from './workflows/dialogs/workflow_abort_dialog.component';
import {WorkflowDialogComponent} from './catalog/workflow/workflow_dialog.component';

import {AuthService}             from './authentication/auth.service';
import {AmqpService}             from './services/amqp.service';
import {ApplicationService}      from './services/application.service';
import {CatalogService}          from './services/catalog.service';
import {ContainerService}        from './services/container.service';
import {ImageService}            from './services/image.service';
import {IMDbService}             from './services/imdb.service';
import {JobService}              from './services/job.service';
import {NodeService}             from './services/node.service';
import {PersonService}           from './services/person.service';
import {RdfService}              from './services/rdf.service';
import {UserService}             from './services/user.service';
import {WatcherService}         from './services/watcher.service';
import {WorkflowService}         from './services/workflow.service';

import {AudioTypePipe}           from './pipes/audio_type.pipe';
import {BasenamePipe}            from './pipes/basename.pipe';
import {DockerImagePipe}         from './pipes/docker_image.pipe';
import {DockerImageVersionPipe}  from './pipes/docker_image_version.pipe';
import {DurationPipe}            from './pipes/duration.pipe';
import {IconForJobPipe}          from './pipes/icon_for_job.pipe';
import {JobDurationPipe}         from './pipes/job_duration.pipe';
import {JobTypePipe}             from './pipes/job_type.pipe';
import {JobStatusPipe}           from './pipes/job_status.pipe';
import {JobStatusIconPipe}       from './pipes/job_status_icon.pipe';
import {ParameterLabelPipe}      from './pipes/parameter_label.pipe';
import {QueuePipe}               from './pipes/queue.pipe';
import {TextTypePipe}            from './pipes/text_type.pipe';
import {VideoTypePipe}           from './pipes/video_type.pipe';

import {TokenInterceptor}        from './authentication/token.interceptor';
import {ErrorInterceptor}        from './authentication/error.interceptor';

import 'hammerjs/hammer'; // for MatSlideToggleModule
import * as moment from 'moment';

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
};

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
    MatProgressSpinnerModule,
    MatRadioModule,
    MatSelectModule,
    MatSidenavModule,
    MatSlideToggleModule,
    MatStepperModule,
    MatTableModule,
    MatToolbarModule,
    SocketModule
  ],
  declarations: [
    AppComponent,
    CatalogComponent,
    ConfirmComponent,
    DashboardComponent,
    DurationComponent,
    IngestComponent,
    JobsComponent,
    JobDetailsDialogComponent,
    LinkImportComponent,
    LoginComponent,
    ParametersComponent,
    PersonComponent,
    PersonFormComponent,
    PersonShowDialogComponent,
    PersonsComponent,
    QueuesComponent,
    RightsComponent,
    StepProgressBarComponent,
    UsersComponent,
    VideoTitleComponent,
    RdfDialogComponent,
    WatchersComponent,
    WorkflowAbortDialogComponent,
    WorkflowDialogComponent,
    WorkflowComponent,
    WorkflowDetailsComponent,
    WorkflowStepDetailsComponent,
    WorkflowsComponent,
    WorkersComponent,

    AudioTypePipe,
    BasenamePipe,
    DockerImagePipe,
    DockerImageVersionPipe,
    DurationPipe,
    IconForJobPipe,
    JobDurationPipe,
    JobTypePipe,
    JobStatusPipe,
    JobStatusIconPipe,
    ParameterLabelPipe,
    QueuePipe,
    TextTypePipe,
    VideoTypePipe,
  ],
  entryComponents: [
    DurationComponent,
    JobDetailsDialogComponent,
    LinkImportComponent,
    ParametersComponent,
    PersonFormComponent,
    PersonShowDialogComponent,
    RdfDialogComponent,
    RightsComponent,
    StepProgressBarComponent,
    VideoTitleComponent,
    WatchersComponent,
    WorkflowComponent,
    WorkflowAbortDialogComponent,
    WorkflowDialogComponent,
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
    ImageService,
    IMDbService,
    JobService,
    NodeService,
    PersonService,
    RdfService,
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
