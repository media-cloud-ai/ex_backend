import { Pipe, PipeTransform } from '@angular/core'
import { Progression } from '../models/job'
/*
 * Usage:
 *   value | jobProgression
 * Example:
 *   {{ [{progression: 50, inserted_at: "16:00:00"}] | jobProgression }}
 *   formats to: 50
*/
@Pipe({name: 'jobProgression'})
export class JobProgressionPipe implements PipeTransform {

  transform(jobProgressions: Progression[]): number {
    var progression = 0;

    if (jobProgressions.length > 0){
      jobProgressions = jobProgressions.sort(this.compare);
      progression = jobProgressions[jobProgressions.length-1].progression;
    }
    
    return progression;
  }

  compare( first: Progression, second: Progression ) {
    var result = 0;
    if ( first.inserted_at < second.inserted_at ){
       result = -1;
    }
    if ( first.inserted_at > second.inserted_at ){
      result = 1;
    }
    return result;
  }
}
