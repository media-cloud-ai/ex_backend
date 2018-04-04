import { Pipe, PipeTransform } from '@angular/core';
import * as moment from 'moment';

/*
 * Usage:
 *   value | iso_duration
 * Examples:
 *   {{ '155414' | duration }}
 *   formats to: "PT2M35.414S"
 *
 *   {{ '155414' | duration : false }}
 *   formats to: "2 m 35 s"
*/
@Pipe({name: 'duration'})
export class DurationPipe implements PipeTransform {

  transform(text: string, iso_format: boolean = true): string {
    let duration = moment.duration(text);
    if(iso_format) {
      return duration.toISOString();
    }

    let display = "";

    let hours = duration.hours();
    let minutes = duration.minutes();
    let seconds = duration.seconds();

    if(hours) {
      display += hours + " h "
    }
    if(minutes) {
      display += minutes + " m "
    }
    if(seconds) {
      display += seconds + " s"
    }

    return display;
  }

}
