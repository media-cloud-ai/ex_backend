import { Pipe, PipeTransform } from '@angular/core'
/*
 * Usage:
 *   value | basename
 * Example:
 *   {{ 'root/foo' | basename }}
 *   formats to: "foo"
 */
@Pipe({ name: 'basename' })
export class BasenamePipe implements PipeTransform {
  transform(path: string): string {
    return path.split(/[\\/]/).pop()
  }
}
