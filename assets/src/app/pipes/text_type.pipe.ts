import { Pipe, PipeTransform } from '@angular/core'
/*
 * Usage:
 *   value | textType
 * Example:
 *   {{ 'francais' | textType }}
 *   formats to: "FR"
 */
@Pipe({ name: 'textType' })
export class TextTypePipe implements PipeTransform {
  transform(text: string): string {
    const allTypes = [{ id: 'francais', name: 'FR' }]

    for (let i = allTypes.length - 1; i >= 0; i--) {
      if (allTypes[i].id === text) {
        return allTypes[i].name
      }
    }
    return text
  }
}
