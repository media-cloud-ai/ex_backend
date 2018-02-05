import { Pipe, PipeTransform } from '@angular/core';
/*
 * Usage:
 *   value | jobType
 * Example:
 *   {{ 'ftp_order' | jobType }}
 *   formats to: "FTP transfer"
*/
@Pipe({name: 'jobType'})
export class JobTypePipe implements PipeTransform {

  transform(jobType: string): string {
    var allJobType = [
      { id: 'ftp_order', name: 'FTP transfer' },
    ];

    for (var i = allJobType.length - 1; i >= 0; i--) {
      if(allJobType[i].id == jobType){
        return allJobType[i].name;
      }
    }
    return jobType;
  }
}
