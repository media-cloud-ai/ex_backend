
import {APP_BASE_HREF}    from '@angular/common';
import {
  HttpClientModule,
  HTTP_INTERCEPTORS
} from '@angular/common/http';
import {NgModule}         from '@angular/core';
import {FormsModule}      from '@angular/forms';
import {BrowserModule}    from '@angular/platform-browser';
import {AppComponent}     from './app.component';
import {
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
  MatSelectModule,
  MatSidenavModule,
  MatSlideToggleModule,
  MatTableModule,
  MatToolbarModule
  } from '@angular/material';

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

import {AppRoutingModule}        from './app-routing.module';

import {ConfirmComponent}        from './confirm/confirm.component';
import {DashboardComponent}      from './dashboard/dashboard.component';
import {DurationComponent}       from './workflows/duration.component';
import {JobsComponent}           from './jobs/jobs.component';
import {LoginComponent}          from './login/login.component';
import {ParametersComponent}     from './workflows/parameters.component';
import {QueuesComponent}         from './amqp/queues.component';
import {UsersComponent}          from './users/users.component';
import {VideosComponent}         from './videos/videos.component';
import {WorkflowComponent}       from './workflows/workflow.component';
import {WorkflowsComponent}      from './workflows/workflows.component';
import {WorkersComponent}        from './workers/workers.component';

import {RdfDialogComponent}      from './videos/rdf/rdf_dialog.component';
import {WorkflowDialogComponent} from './videos/workflow/workflow_dialog.component';

import {AuthService}             from './authentication/auth.service';
import {AmqpService}             from './services/amqp.service';
import {ContainerService}        from './services/container.service';
import {ImageService}            from './services/image.service';
import {JobService}              from './services/job.service';
import {NodeService}             from './services/node.service';
import {RdfService}              from './services/rdf.service';
import {UserService}             from './services/user.service';
import {VideoService}            from './services/video.service';
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

import {TokenInterceptor}        from './authentication/token.interceptor';

import 'hammerjs/hammer'; // for MatSlideToggleModule
import * as moment from 'moment';

const SUBTIL_DATE_FORMATS = {
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
    MatSelectModule,
    MatSidenavModule,
    MatSlideToggleModule,
    MatTableModule,
    MatToolbarModule
  ],
  declarations: [
    AppComponent,
    ConfirmComponent,
    DashboardComponent,
    DurationComponent,
    JobsComponent,
    LoginComponent,
    ParametersComponent,
    QueuesComponent,
    UsersComponent,
    VideosComponent,
    RdfDialogComponent,
    WorkflowDialogComponent,
    WorkflowComponent,
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
  ],
  entryComponents: [
    DurationComponent,
    ParametersComponent,
    RdfDialogComponent,
    WorkflowComponent,
    WorkflowDialogComponent,
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
      useValue: SUBTIL_DATE_FORMATS
    },
    {
      provide: HTTP_INTERCEPTORS,
      useClass: TokenInterceptor,
      multi: true
    },
    AmqpService,
    AuthService,
    ContainerService,
    ImageService,
    JobService,
    NodeService,
    RdfService,
    UserService,
    VideoService,
    WorkflowService,
  ],
  bootstrap: [
    AppComponent
  ]
})

export class AppModule { }
