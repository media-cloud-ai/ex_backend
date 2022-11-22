import { Component, Input } from '@angular/core'

import { Subtitle } from '../../models/registery'

@Component({
  selector: 'subtitle-component',
  templateUrl: 'subtitle.component.html',
  styleUrls: ['./subtitle.component.less'],
})
export class SubtitleComponent {
  @Input() subtitle: Subtitle
}
