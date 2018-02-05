import { Pipe, PipeTransform } from '@angular/core';
import { Status } from '../services/job';
/*
 * Usage:
 *   value | jobStatus
 * Example:
 *   {{ [{state: 'completed'}] | jobStatus }}
 *   formats to: "completed"
*/
@Pipe({name: 'jobStatus'})
export class JobStatusPipe implements PipeTransform {

  transform(jobStatus: Status[]): string {
    console.log(jobStatus)

    for (var i = jobStatus.length - 1; i >= 0; i--) {
      if(jobStatus[i].state == "completed"){
        return "completed";
      }
      if(jobStatus[i].state == "error"){
        return "error";
      }
    }
    return "processing";
  }
}
