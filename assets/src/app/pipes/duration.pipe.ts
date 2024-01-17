import { Pipe, PipeTransform } from '@angular/core'
import * as moment from 'moment'

/*
 * Usage:
 *   value | iso_duration
 * Examples:
 *   {{ '155414' | duration }}
 *   formats to: "PT2M35.414S"
 *   {{ '155414' | duration : 'iso' }}
 *   formats to: "PT2M35.414S"
 *   {{ '155414' | duration : 'human' }}
 *   formats to: "2 m 35 s"
 *   {{ '155414' | duration : 'timecode_frame' }}
 *   formats to: "00:02:35:10"
 *   {{ '155414' | duration : 'timecode_ms' }}
 *   formats to: "00:02:35.414"
 */
@Pipe({ name: 'duration' })
export class DurationPipe implements PipeTransform {
  private fps = 25

  pad_left(value: number, width: number, char: string): string {
    const text = value.toString()
    if (text.length >= width) {
      return text
    }
    const padding = new Array(width - text.length + 1).join(char)
    return padding + text
  }

  transform(text: any, format = 'iso'): string {
    if (text == undefined) {
      return ''
    }

    const duration = moment.duration(text)
    if (format === 'iso') {
      return duration.toISOString()
    }

    if (format === 'human') {
      return duration.humanize()
    }

    let display = ''
    const days = duration.days()
    const hours = duration.hours() + 24 * days
    const minutes = duration.minutes()
    const seconds = duration.seconds()

    display =
      this.pad_left(hours, 2, '0') +
      ':' +
      this.pad_left(minutes, 2, '0') +
      ':' +
      this.pad_left(seconds, 2, '0')

    if (format === 'timecode_frame') {
      const frame_duration = 1000 / this.fps
      const frames = Math.floor(duration.milliseconds() / frame_duration)
      display += ':' + this.pad_left(frames, 2, '0')
      return display
    }

    if (format === 'timecode_ms') {
      display +=
        '.' + this.pad_left(Math.round(duration.milliseconds()), 3, '0')
      return display
    }

    return text
  }
}
