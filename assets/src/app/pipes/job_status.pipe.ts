import { Pipe, PipeTransform } from '@angular/core'
import { Job } from '../models/job'
/*
 * Usage:
 *   value | jobStatus
 * Example:
 *   {{ [{state: 'completed'}] | jobStatus }}
 *   formats to: "completed"
 */
@Pipe({ name: 'jobStatus' })
export class JobStatusPipe implements PipeTransform {
  transform(job: Job): string {
    var jobStatus = Job.getLastStatus(job)
    var jobProgression = Job.getLastProgression(job)

    if (!jobStatus) {
      if (jobProgression) {
        return 'processing'
      } else {
        return 'queued'
      }
    } else if (
      [
        'completed',
        'error',
        'paused',
        'skipped',
        'stopped',
        'queued',
        'dropped',
      ].includes(jobStatus.state)
    ) {
      return jobStatus.state
    } else if (jobStatus.state === 'retrying') {
      if (!jobProgression || jobProgression.datetime < jobStatus.inserted_at) {
        return 'queued'
      }
    }

    return 'processing'
  }
}
