import {
  AfterViewInit,
  Component,
  ElementRef,
  Inject,
  ViewChild,
  ViewEncapsulation,
} from '@angular/core'
import { DOCUMENT } from '@angular/common'
import { SwaggerUIBundle, SwaggerUIStandalonePreset } from 'swagger-ui-dist'
import 'swagger-ui-dist/swagger-ui.css'
import { AuthService } from '../authentication/auth.service'

@Component({
  selector: 'documentation-component',
  templateUrl: 'documentation.component.html',
  styleUrls: ['./documentation.component.less'],
  encapsulation: ViewEncapsulation.None,
})
export class DocumentationComponent implements AfterViewInit {
  private token: string

  constructor(
    @Inject(DOCUMENT) private document: Document,
    private authService: AuthService,
  ) {
    this.token = authService.getToken()
  }

  @ViewChild('swagger_backend') swaggerDomBackend: ElementRef<HTMLDivElement>
  @ViewChild('swagger_stepflow') swaggerDomStepFlow: ElementRef<HTMLDivElement>

  ngAfterViewInit() {
    SwaggerUIBundle({
      urls: [
        {
          name: 'MCAI Backend',
          url: this.document.location.origin + '/api/backend/openapi',
        },
      ],
      domNode: this.swaggerDomBackend.nativeElement,
      deepLinking: true,
      presets: [SwaggerUIBundle.presets.apis, SwaggerUIStandalonePreset],
      layout: 'StandaloneLayout',
      withCredentials: true,
      requestInterceptor: (request) => {
        request.headers = {
          Accept: 'application/json,*/*',
          Authorization: this.token,
        }
        return request
      },
    })

    SwaggerUIBundle({
      urls: [
        {
          name: 'StepFlow',
          url: this.document.location.origin + '/api/step_flow/openapi',
        },
      ],
      domNode: this.swaggerDomStepFlow.nativeElement,
      deepLinking: true,
      presets: [SwaggerUIBundle.presets.apis, SwaggerUIStandalonePreset],
      layout: 'StandaloneLayout',
      withCredentials: true,
      requestInterceptor: (request) => {
        request.headers = {
          Accept: 'application/json,*/*',
          Authorization: this.token,
        }
        return request
      },
    })
  }
}
