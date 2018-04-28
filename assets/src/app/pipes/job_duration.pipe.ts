import { Pipe, PipeTransform } from '@angular/core';
import { Job, Status } from '../models/job';
import * as moment from 'moment';

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
    var start = +new Date(job.inserted_at);
    if(job.status[0] == undefined) {
      console.log(moment.utc(), start, moment().utcOffset());
      return moment().add(-moment().utcOffset(), 'minutes').diff(start);
    }

    var end = +new Date(job.status[0].inserted_at);
    return (end - start);
  }
}
