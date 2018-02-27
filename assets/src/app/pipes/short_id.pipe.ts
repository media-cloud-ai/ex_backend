import { Pipe, PipeTransform } from '@angular/core';
/*
 * Usage:
 *   value | short_id
 * Example:
 *   {{ '0123456789abcdef' | short_id }}
 *   formats to: "0123456789ab"
*/
@Pipe({name: 'short_id'})
export class ShortIdPipe implements PipeTransform {

  transform(id: string): string {
    return id.slice(0, 12);
  }
}
