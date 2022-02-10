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
    var jobStatus = Job.getLastStatus(job)
    var jobProgression = Job.getLastProgression(job)

    if (!jobStatus){
      if (jobProgression){
        return 'processing'
      } else {
        return 'queued'
      }
    } else {
      if (jobStatus.state === 'completed'){
        return 'completed'
      }
      if (jobStatus.state === 'error'){
        status = 'error'
      }
      if (jobStatus.state === 'paused'){
        return 'paused'
      }
      if (jobStatus.state === 'skipped'){
        return 'skipped'
      }
      if (jobStatus.state === 'stopped'){
        return 'stopped'
      }
      if (status != "error" && jobStatus.state === 'retrying'){
        if (!jobProgression || jobProgression.datetime < jobStatus.inserted_at) {
          return "queued"
        }
        return 'processing'
      }
    }
    if (status === undefined) {
      return 'processing'
    } else {
      return status
    }
  }
}


