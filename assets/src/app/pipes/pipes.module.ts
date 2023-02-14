import { NgModule } from '@angular/core'
import { CommonModule } from '@angular/common'

import { AudioTypePipe } from './audio_type.pipe'
import { BasenamePipe } from './basename.pipe'
import { BytesPipe } from './bytes.pipe'
import { DurationPipe } from './duration.pipe'
import { IconForJobPipe } from './icon_for_job.pipe'
import { JobDurationPipe } from './job_duration.pipe'
import { JobTypePipe } from './job_type.pipe'
import { JobProgressionPipe } from './job_progression.pipe'
import { JobStatusPipe } from './job_status.pipe'
import { JobStatusIconPipe } from './job_status_icon.pipe'
import { LanguagePipe } from './language.pipe'
import { NumberToArrayPipe } from './number_to_array.pipe'
import { ParameterLabelPipe } from './parameter_label.pipe'
import { QueuePipe } from './queue.pipe'
import { TextTypePipe } from './text_type.pipe'
import { VideoTypePipe } from './video_type.pipe'

@NgModule({
  imports: [CommonModule],
  declarations: [
    AudioTypePipe,
    BasenamePipe,
    BytesPipe,
    DurationPipe,
    IconForJobPipe,
    JobDurationPipe,
    JobTypePipe,
    JobProgressionPipe,
    JobStatusPipe,
    JobStatusIconPipe,
    LanguagePipe,
    NumberToArrayPipe,
    ParameterLabelPipe,
    QueuePipe,
    TextTypePipe,
    VideoTypePipe,
  ],
  exports: [
    AudioTypePipe,
    BasenamePipe,
    BytesPipe,
    DurationPipe,
    IconForJobPipe,
    JobDurationPipe,
    JobTypePipe,
    JobProgressionPipe,
    JobStatusPipe,
    JobStatusIconPipe,
    LanguagePipe,
    NumberToArrayPipe,
    ParameterLabelPipe,
    QueuePipe,
    TextTypePipe,
    VideoTypePipe,
  ],
})
export class PipesModule {}
