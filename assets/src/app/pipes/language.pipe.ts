import { Pipe, PipeTransform } from '@angular/core'
/*
 * Usage:
 *   value | language
 * Example:
 *   {{ 'french' | language }}
 *   formats to: "French"
*/
@Pipe({name: 'language'})
export class LanguagePipe implements PipeTransform {
  transform(language: string): string {
    var allLanguages = [
      { id: 'english', name: 'English' },
      { id: 'eng', name: 'English' },
      { id: 'french', name: 'French' },
      { id: 'fre', name: 'French' },
      { id: 'fra', name: 'French' },
    ]

    for (var i = allLanguages.length - 1; i >= 0; i--) {
      if (allLanguages[i].id === language.split(':')[0]){
        return allLanguages[i].name
      }
    }
    return language
  }
}
