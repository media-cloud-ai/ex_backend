import { Pipe, PipeTransform } from '@angular/core';
/*
 * Usage:
 *   value | iconForJob
 * Example:
 *   {{ 'download_ftp' | iconForJob }}
 *   formats to: "file_download"
*/
@Pipe({name: 'iconForJob'})
export class IconForJobPipe implements PipeTransform {

  transform(iconForJob: string): string {
    var allJobIcons = [
      { id: 'download_ftp', name: 'file_download' },
      { id: 'upload_ftp', name: 'file_upload' },
      { id: 'generate_dash', name: 'tv' },
    ];

    for (var i = allJobIcons.length - 1; i >= 0; i--) {
      if(allJobIcons[i].id == iconForJob){
        return allJobIcons[i].name;
      }
    }
    return "settings";
  }
}
