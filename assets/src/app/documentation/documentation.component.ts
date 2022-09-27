import {
  AfterViewInit,
  Component,
  ElementRef,
  ViewChild,
  ViewEncapsulation
} from '@angular/core';
import { SwaggerUIBundle, SwaggerUIStandalonePreset } from 'swagger-ui-dist';

@Component({
  selector: 'documentation-component',
  templateUrl: 'documentation.component.html',
  styleUrls: ['./documentation.component.less'],
  encapsulation: ViewEncapsulation.None,
})
export class DocumentationComponent implements AfterViewInit {
  @ViewChild('swagger') swaggerDom: ElementRef<HTMLDivElement>;

  ngAfterViewInit() {
    SwaggerUIBundle({
      urls: [
        {
          name: 'MCAI Backend',
          url: 'http://localhost:4000/swagger/backend/backend_swagger.json'
        },
        {
          name: 'Step Flow',
          url: 'http://localhost:4000/swagger/step_flow/step_flow_swagger.json'
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
