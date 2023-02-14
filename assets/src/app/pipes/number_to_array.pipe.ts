import { Pipe, PipeTransform } from '@angular/core'
/*
 * Usage:
 *   value | numberToArray
 * Example:
 *   {{ 5 | numberToArray }}
 *   formats to: [1, 2, 3, 4, 5]
 */
@Pipe({ name: 'numberToArray' })
export class NumberToArrayPipe implements PipeTransform {
  transform(value): any {
    const res = []
    for (let i = 0; i < value; i++) {
      res.push(i)
    }
    return res
  }
}
