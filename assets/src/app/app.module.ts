
import {APP_BASE_HREF} from '@angular/common';
import {HttpClientModule} from '@angular/common/http';
import {NgModule}      from '@angular/core';
import {BrowserModule} from '@angular/platform-browser';
import {AppComponent}  from './app.component';
import {MatMenuModule} from '@angular/material';
import {MatSidenavModule} from '@angular/material/sidenav';
import {MatToolbarModule} from '@angular/material/toolbar';
import {BrowserAnimationsModule} from '@angular/platform-browser/animations';
import {MatPaginatorModule} from '@angular/material/paginator';

import {RouterModule, Routes} from '@angular/router';

import {VideosComponent}      from './videos/videos.component';
import {DashboardComponent}      from './dashboard/dashboard.component';

import {VideoService}          from './services/video.service';

const routes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  { path: 'dashboard', component: DashboardComponent },
  { path: 'videos', component: VideosComponent }
];

@NgModule({
  exports: [
    RouterModule
  ],
  imports: [
    BrowserModule,
    HttpClientModule,
    MatMenuModule,
    MatSidenavModule,
    MatToolbarModule,
    MatPaginatorModule,
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
    VideoService
  ],
  bootstrap: [
    AppComponent
  ]
})

export class AppModule { }
