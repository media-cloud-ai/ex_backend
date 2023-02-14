import { Pipe, PipeTransform } from '@angular/core'
/*
 * Usage:
 *   value | audioType
 * Example:
 *   {{ 'francais' | audioType }}
 *   formats to: "FR"
 */
@Pipe({ name: 'audioType' })
export class AudioTypePipe implements PipeTransform {
  transform(audio: string): string {
    const allTypes = [
      { id: 'francais', name: 'FR' },
      { id: 'audiodescription', name: 'AD' },
      { id: 'version-originale', name: 'VO' },
    ]

    for (let i = allTypes.length - 1; i >= 0; i--) {
      if (allTypes[i].id === audio) {
        return allTypes[i].name
      }
    }
    return audio
  }
}
