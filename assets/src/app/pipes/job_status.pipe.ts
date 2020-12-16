import { Pipe, PipeTransform } from '@angular/core'
import { Job } from '../models/job'
/*
 * Usage:
 *   value | jobStatus
 * Example:
 *   {{ [{state: 'completed'}] | jobStatus }}
 *   formats to: "completed"
*/
@Pipe({name: 'jobStatus'})
export class JobStatusPipe implements PipeTransform {

  transform(job: Job): string {
    var status = undefined
    var jobStatus = job.status
    var jobProgression = job.progressions
    if (jobStatus.length === 0){
      if (jobProgression.length > 0){
        return 'processing'
      } else {
        return 'queued'
      }
    } else {
      for (var i = jobStatus.length - 1; i >= 0; i--) {
        if (jobStatus[i].state === 'completed'){
          return 'completed'
        }
        if (jobStatus[i].state === 'error'){
          status = 'error'
        }
        if (jobStatus[i].state === 'skipped'){
          return 'skipped'
        }
      }
    }
    if (status === undefined) {
      return 'processing'
    } else {
      return status
    }
  }
}
