import { Pipe, PipeTransform } from '@angular/core'
/*
 * Usage:
 *   value | language
 * Example:
 *   {{ 'fra' | language }}
 *   formats to: "French"
 */
@Pipe({ name: 'language' })
export class LanguagePipe implements PipeTransform {
  transform(language: string): string {
    var allLanguages = [
      { id: 'eng', name: 'English' },
      { id: 'fre', name: 'French' },
      { id: 'fra', name: 'French' },
      { id: 'deu', name: 'Deutch' },
      { id: 'spa', name: 'Spanish' },
      { id: 'ita', name: 'Italian' },
    ]

    for (var i = allLanguages.length - 1; i >= 0; i--) {
      if (allLanguages[i].id === language.split(':')[0]) {
        return allLanguages[i].name
      }
    }
    return language
  }
}
