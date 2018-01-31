
import {APP_BASE_HREF} from '@angular/common';
import {HttpClientModule} from '@angular/common/http';
import {NgModule}      from '@angular/core';
import {FormsModule} from '@angular/forms';
import {BrowserModule} from '@angular/platform-browser';
import {AppComponent}  from './app.component';
import {MatMenuModule} from '@angular/material';
import {MatInputModule} from '@angular/material';
import {MatSidenavModule} from '@angular/material/sidenav';
import {MatToolbarModule} from '@angular/material/toolbar';
import {BrowserAnimationsModule} from '@angular/platform-browser/animations';
import {MatPaginatorModule} from '@angular/material/paginator';
import {MatSelectModule} from '@angular/material/select';
import {MatButtonModule} from '@angular/material/button';
import {MatSlideToggleModule} from '@angular/material/slide-toggle';
import {MatIconModule} from '@angular/material/icon';

import {MatDatepickerModule} from '@angular/material/datepicker';
import {MomentDateAdapter, MatMomentDateModule, MAT_MOMENT_DATE_FORMATS} from '@angular/material-moment-adapter';
import {DateAdapter, MAT_DATE_LOCALE, MAT_DATE_FORMATS} from '@angular/material/core';

import {RouterModule, Routes} from '@angular/router';

import {VideosComponent}      from './videos/videos.component';
import {DashboardComponent}      from './dashboard/dashboard.component';

import {VideoService}          from './services/video.service';

import 'hammerjs/hammer'; // for MatSlideToggleModule
import * as moment from 'moment';

const routes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  { path: 'dashboard', component: DashboardComponent },
  { path: 'videos', component: VideosComponent }
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
    BrowserModule,
    HttpClientModule,
    FormsModule,
    MatMenuModule,
    MatInputModule,
    MatSidenavModule,
    MatToolbarModule,
    MatPaginatorModule,
    MatSelectModule,
    MatButtonModule,
    MatSlideToggleModule,
    MatIconModule,
    MatDatepickerModule,
    MatMomentDateModule,
    BrowserAnimationsModule,
    RouterModule.forRoot(routes)
  ],
  declarations: [
    AppComponent,
    DashboardComponent,
    VideosComponent
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
    VideoService
  ],
  bootstrap: [
    AppComponent
  ]
})

export class AppModule { }
