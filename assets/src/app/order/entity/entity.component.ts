import { Component, Input } from '@angular/core'
import { Entity } from '../../models/nlp_entity'

@Component({
  selector: 'entity-component',
  templateUrl: 'entity.component.html',
  styleUrls: ['./entity.component.less'],
})
export class EntityComponent {
  @Input() entities: Entity[]
  @Input() word: string
  @Input() index: number

  getStyle(index: number) {
    var colors: string[] = ['#afd5aa', '#90c978', '#83c6dd', '#5db1d1']
    var color: string = colors[(index % colors.length).toString()]
    return {
      'background-color': color,
      'padding-top': '3px',
      'padding-bottom': '3px',
      'padding-left': '2px',
      'padding-right': '2px',
      'margin-right': '-1.65px',
      'margin-left': '-1.65px',
      'border-radius': '3px',
    }
  }

  mergedLeft(word: string): boolean {
    return [',', '.', ';'].includes(word) || word.startsWith('-')
  }

  mergedRight(word: string): boolean {
    return word.endsWith('(') || word.endsWith("'") || word.endsWith('-')
  }
}
