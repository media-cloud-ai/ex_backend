import { Injectable } from '@angular/core'
import {
  HttpRequest,
  HttpHandler,
  HttpEvent,
  HttpInterceptor,
  HttpErrorResponse,
} from '@angular/common/http'

import { AuthService } from './auth.service'
import { catchError, Observable, tap, throwError } from 'rxjs'

@Injectable()
export class ErrorInterceptor implements HttpInterceptor {
  constructor(public authService: AuthService) {}

  intercept(
    req: HttpRequest<any>,
    next: HttpHandler,
  ): Observable<HttpEvent<any>> {
    return next.handle(req).pipe(
      tap((_event) => {
        //do nothing
      }),
      catchError((err) => this.handleError(err)),
    )
  }

  private handleError(err_object: HttpErrorResponse): Observable<never> {
    if (err_object.status === 401) {
      console.error(err_object)
      this.authService.logout(false).subscribe()
      return throwError(() => new Error(err_object.status.toString()))
    }
  }
}
