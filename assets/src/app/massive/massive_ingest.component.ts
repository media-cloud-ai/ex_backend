
import {Component} from '@angular/core'
  
@Component({
  selector: 'massive-ingest-component',
  templateUrl: 'massive_ingest.component.html',
  styleUrls: ['massive_ingest.component.less']
})

export class MassiveIngestComponent {

  channels = [
    {id: 'france-2', label: 'France 2'},
    {id: 'france-3', label: 'France 3'},
    {id: 'france-4', label: 'France 4'},
    {id: 'france-5', label: 'France 5'},
    {id: 'france-o', label: 'France Ô'}
  ]
  selectedChannels = []
  live = false
  integrale = false

  constructor(
  ) {
  }

  ngOnInit() {
  }
}
