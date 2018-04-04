import { Pipe, PipeTransform } from '@angular/core';
import * as moment from 'moment';

/*
 * Usage:
 *   value | timecode
 * Example:
 *   {{ 'PT2M35S' | timecode }}
 *   formats to: "00:02:35:00"
*/
@Pipe({name: 'timecode'})
export class TimecodePipe implements PipeTransform {

  private fps = 25;

  pad_left(value: number, width: number, char: string): string {
    let text = value.toString();
    if(text.length >= width) {
      return text;
    }
    let padding = new Array(width - text.length + 1).join(char);
    return padding + text;
  }

  transform(text: string): string {
    let duration = moment.duration(text);

    let frame_duration = 1000 / this.fps;
    let frames = Math.floor(duration.milliseconds() / frame_duration);

    let seconds = duration.seconds();
    let minutes = duration.minutes();
    let hours = duration.hours();

    // console.log("hours:", hours, "minutes:", minutes, "seconds:", seconds, "frames:", frames);

    return this.pad_left(hours, 2, '0') + ":"
         + this.pad_left(minutes, 2, '0') + ":"
         + this.pad_left(seconds, 2, '0') + ":"
         + this.pad_left(frames, 2, '0');

  }
}
