import { NgModule } from '@angular/core'
import { CommonModule } from '@angular/common'
import { Routes, RouterModule } from '@angular/router'
import { FormsModule } from '@angular/forms'

import { PlayerComponent } from './player.component'
import { SubtitleComponent } from './subtitle.component'
import { TimecodeComponent } from './timecode.component'
import { TimecodeDialogComponent } from './dialog/timecode_dialog.component'
import { SetVersionDialog } from './dialog/set_version_dialog'

import { MatButtonModule } from '@angular/material/button'
import { MatDialogModule } from '@angular/material/dialog'
import { MatIconModule } from '@angular/material/icon'
import { MatInputModule } from '@angular/material/input'
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner'
import { MatSelectModule } from '@angular/material/select'
import { MatSliderModule } from '@angular/material/slider'

import { PipesModule } from '../pipes/pipes.module'

import * as dashjs from 'dashjs'

export const ROUTES: Routes = [{ path: '', component: PlayerComponent }]

@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    MatButtonModule,
    MatDialogModule,
    MatIconModule,
    MatInputModule,
    MatProgressSpinnerModule,
    MatSelectModule,
    MatSliderModule,
    PipesModule,
    RouterModule.forChild(ROUTES),
  ],
  declarations: [
    PlayerComponent,
    SubtitleComponent,
    TimecodeComponent,
    TimecodeDialogComponent,
    SetVersionDialog,
  ],
  entryComponents: [
    SubtitleComponent,
    TimecodeComponent,
    TimecodeDialogComponent,
    SetVersionDialog,
  ],
})
export class PlayerModule {}
