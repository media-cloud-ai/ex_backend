import {
  AfterViewInit,
  Component,
  ElementRef,
  Inject,
  ViewChild,
  ViewEncapsulation
} from '@angular/core';
import {
  DOCUMENT
} from '@angular/common';
import { SwaggerUIBundle, SwaggerUIStandalonePreset } from 'swagger-ui-dist';

@Component({
  selector: 'documentation-component',
  templateUrl: 'documentation.component.html',
  styleUrls: ['./documentation.component.less'],
  encapsulation: ViewEncapsulation.None,
})

export class DocumentationComponent implements AfterViewInit {
  constructor(@Inject(DOCUMENT) private document: Document) {}

  @ViewChild('swagger') swaggerDom: ElementRef<HTMLDivElement>;

  ngAfterViewInit() {
    SwaggerUIBundle({
      urls: [
        {
          name: 'MCAI Backend',
          url: this.document.location.origin+'/swagger/backend/backend_swagger.json'
        },
        {
          name: 'StepFlow',
          url: this.document.location.origin+'/swagger/step_flow/step_flow_swagger.json'
        }
      ],
      domNode: this.swaggerDom.nativeElement,
      deepLinking: true,
      presets: [
        SwaggerUIBundle.presets.apis,
        SwaggerUIStandalonePreset
      ],
      layout: 'StandaloneLayout'
    });
  }
}
