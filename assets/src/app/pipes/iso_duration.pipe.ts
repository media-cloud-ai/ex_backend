import { Pipe, PipeTransform } from '@angular/core';
import * as moment from 'moment';

/*
 * Usage:
 *   value | iso_duration
 * Example:
 *   {{ '155414' | iso_duration }}
 *   formats to: "PT2M35.414S"
*/
@Pipe({name: 'iso_duration'})
export class IsoDurationPipe implements PipeTransform {

  transform(text: string): string {
    return moment.duration(text).toISOString();
  }

}
