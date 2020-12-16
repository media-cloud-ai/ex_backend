import { Pipe, PipeTransform } from '@angular/core'
import { Progression } from '../models/job'
/*
 * Usage:
 *   value | jobProgression
 * Example:
 *   {{ [{progression: 50, inserted_at: "16:00:00"}] | jobProgression }}
 *   formats to: 50
*/
@Pipe({ name: 'jobProgression' })
export class JobProgressionPipe implements PipeTransform {

  transform(jobProgressions: Progression[]): number {
    var progression = 0;

    if (jobProgressions.length > 0) {
      jobProgressions = jobProgressions.sort(this.compare);
      progression = jobProgressions[jobProgressions.length - 1].progression;
    }

    return progression;
  }

  compare(first: Progression, second: Progression) {
    let dateFirst = new Date(first.datetime);
    let dateSecond = new Date(second.datetime);

    if (dateFirst < dateSecond) {
      return -1;
    }

    if (dateFirst > dateSecond) {
      return 1;
    }

    if (first.progression < second.progression) {
      return -1;
    }

    if (first.progression > second.progression) {
      return 1;
    }

    return 0;
  }
}
