import { Injectable } from '@angular/core'
import {
  HttpRequest,
  HttpHandler,
  HttpEvent,
  HttpInterceptor
} from '@angular/common/http'

import { AuthService } from './auth.service'
import { Observable } from 'rxjs'

@Injectable()
export class TokenInterceptor implements HttpInterceptor {
  constructor(public auth: AuthService) {}
  intercept(request: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    // console.log(request)
    if (request.url.startsWith('https://staticftv-a.akamaihd.net')) {
      return next.handle(request)
    }
    request = request.clone({
      setHeaders: {
        Authorization: `${this.auth.getToken()}`
      }
    })
    return next.handle(request)
  }
}
