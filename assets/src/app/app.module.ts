
import {APP_BASE_HREF}    from '@angular/common';
import {HttpClientModule} from '@angular/common/http';
import {NgModule}         from '@angular/core';
import {FormsModule}      from '@angular/forms';
import {BrowserModule}    from '@angular/platform-browser';
import {AppComponent}     from './app.component';
import {
  MatButtonModule,
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

import {DashboardComponent}      from './dashboard/dashboard.component';
import {JobsComponent}           from './jobs/jobs.component';
import {QueuesComponent}         from './amqp/queues.component';
import {VideosComponent}         from './videos/videos.component';
import {WorkflowsComponent}      from './workflows/workflows.component';

import {WorkflowDialogComponent} from './videos/workflow/workflow_dialog.component';

import {AmqpService}             from './services/amqp.service';
import {JobService}              from './services/job.service';
import {VideoService}            from './services/video.service';
import {WorkflowService}         from './services/workflow.service';

import {BasenamePipe}            from './pipes/basename.pipe';
import {IconForJobPipe}          from './pipes/icon_for_job.pipe';
import {JobTypePipe}             from './pipes/job_type.pipe';
import {JobStatusPipe}           from './pipes/job_status.pipe';
import {ParameterLabelPipe}      from './pipes/parameter_label.pipe';
import {QueuePipe}               from './pipes/queue.pipe';

import 'hammerjs/hammer'; // for MatSlideToggleModule
import * as moment from 'moment';

const routes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  { path: 'dashboard', component: DashboardComponent },
  { path: 'videos', component: VideosComponent },
  { path: 'jobs', component: JobsComponent },
  { path: 'workflows', component: WorkflowsComponent }
];

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
    BrowserAnimationsModule,
    BrowserModule,
    FormsModule,
    HttpClientModule,
    MatButtonModule,
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
    MatToolbarModule,
    RouterModule.forRoot(routes)
  ],
  declarations: [
    AppComponent,
    DashboardComponent,
    JobsComponent,
    QueuesComponent,
    VideosComponent,
    WorkflowDialogComponent,
    WorkflowsComponent,

    IconForJobPipe,
    BasenamePipe,
    JobTypePipe,
    JobStatusPipe,
    ParameterLabelPipe,
    QueuePipe,
  ],
  entryComponents: [
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
    AmqpService,
    JobService,
    VideoService,
    WorkflowService,
  ],
  bootstrap: [
    AppComponent
  ]
})

export class AppModule { }
