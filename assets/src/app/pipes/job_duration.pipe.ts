import { Pipe, PipeTransform } from '@angular/core';
import { Job, Status } from '../models/job';
/*
 * Usage:
 *   value | jobDuration
 * Example:
 *   {{ job | jobDuration }}
 *   formats to: 99614
*/
@Pipe({name: 'jobDuration'})
export class JobDurationPipe implements PipeTransform {

  transform(job: Job): number {
    var end = +new Date(job.status[0].inserted_at);
    var start = +new Date(job.inserted_at);
    return (end - start);
  }
}
