import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import {VideoTitleComponent} from './video_title.component'


@NgModule({
  imports: [
    CommonModule,
  ],
  declarations: [
    VideoTitleComponent,
  ],
  exports: [
    VideoTitleComponent,
  ],
})

export class GenericModule { }
