
import {Component} from '@angular/core'
import {DocumentationService} from '../services/documentation.service'

@Component({
  selector: 'documentation-component',
  templateUrl: 'documentation.component.html',
  styleUrls: ['./documentation.component.less'],
})

export class DocumentationComponent {
  documentation: any

  constructor(
    private documentationService: DocumentationService
  ) {}

  ngOnInit() {
    this.documentationService.getDocumentation()
    .subscribe(response => {
      this.documentation = response
    })
  }
}
