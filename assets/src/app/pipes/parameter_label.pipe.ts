import { Pipe, PipeTransform } from '@angular/core';
/*
 * Usage:
 *   value | parameterLabel
 * Example:
 *   {{ 'segment_duration' | parameterLabel }}
 *   formats to: "Segment Duration"
*/
@Pipe({name: 'parameterLabel'})
export class ParameterLabelPipe implements PipeTransform {

  transform(parameterLabel: string): string {
    var allLabels = [
      { id: 'segment_duration', name: 'Segment Duration' },
      { id: 'fragment_duration', name: 'Fragment Duration' },
    ];

    for (var i = allLabels.length - 1; i >= 0; i--) {
      if(allLabels[i].id == parameterLabel){
        return allLabels[i].name;
      }
    }
    return parameterLabel;
  }
}
