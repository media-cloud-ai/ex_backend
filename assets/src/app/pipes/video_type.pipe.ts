import { Pipe, PipeTransform } from '@angular/core'
/*
 * Usage:
 *   value | videoType
 * Example:
 *   {{ 'extrait' | videoType }}
 *   formats to: "Extrait"
*/
@Pipe({name: 'videoType'})
export class VideoTypePipe implements PipeTransform {

  transform(text: string): string {
    var allTypes = [
      { id: 'making-of', name: 'Making-of' },
      { id: 'interview', name: 'Interview' },
      { id: 'teaser', name: 'Teaser' },
      { id: 'resume', name: 'Résumé' },
      { id: 'bonus', name: 'Bonus' },
      { id: 'bande-annonce', name: 'Bande-Annonce' },
      { id: 'extrait', name: 'Extrait' },
      { id: 'integrale', name: 'Intégrale' },
      { id: 'flux', name: 'Flux' },
    ]

    for (var i = allTypes.length - 1; i >= 0; i--) {
      if (allTypes[i].id === text){
        return allTypes[i].name
      }
    }
    return text
  }
}
