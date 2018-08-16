import { Pipe, PipeTransform } from '@angular/core'
/*
 * Usage:
 *   value | dockerImageVersion
 * Example:
 *   {{ 'ftvsubtil/http_worker:release-0.1.0' | dockerImageVersion }}
 *   formats to: "V 0.1.0"
*/
@Pipe({name: 'dockerImageVersion'})
export class DockerImageVersionPipe implements PipeTransform {
  transform(image_name: string): string {
    var tag = image_name.split(':')[1]

    if (tag === undefined || tag === 'latest') {
      return 'Latest'
    }
    
    if (tag.startsWith('release-')) {
      return 'v' + tag.replace('release-', '')
    }

    return tag
  }
}
