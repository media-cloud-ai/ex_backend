import { Injectable } from '@angular/core'
import {
  HttpRequest,
  HttpHandler,
  HttpEvent,
  HttpResponse,
  HttpInterceptor,
  HttpErrorResponse,
} from '@angular/common/http'

import { AuthService } from './auth.service'
import { Observable } from 'rxjs'
import 'rxjs/add/operator/do'

@Injectable()
export class ErrorInterceptor implements HttpInterceptor {
  constructor(public authService: AuthService) {}

  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    return next.handle(req).do(event => {}, err => {
      if (err instanceof HttpErrorResponse && err.status === 401) {
        this.authService.logout()
      }
    })
  }
}
