import { Injectable } from '@angular/core'
import { HttpClient } from '@angular/common/http'
import { Observable, of } from 'rxjs'
import { catchError, tap } from 'rxjs/operators'

import { NotificationTemplate } from '../models/notification_template'
import { NotificationTemplatePage } from '../models/page/notification_template_page'

@Injectable()
export class NotificationTemplateService {
  private notificationTemplatesUrl = '/api/step_flow/notification_templates'

  constructor(private http: HttpClient) {}

  getNotificationTemplates(): Observable<NotificationTemplatePage> {
    return this.http
      .get<NotificationTemplatePage>(this.notificationTemplatesUrl)
      .pipe(
        tap((_notificationTemplatePage) =>
          this.log('fetched NotificationTemplatePage'),
        ),
        catchError(this.handleError('getNotificationTemplates', undefined)),
      )
  }

  createNotificationTemplate(
    template_name: string,
    template_headers: string,
    template_body: string,
  ): Observable<NotificationTemplate> {
    const params = {
      template_name: template_name,
      template_headers: template_headers,
      template_body: template_body,
    }
    return this.http
      .post<NotificationTemplate>(this.notificationTemplatesUrl, params)
      .pipe(
        tap((_notificationTemplatePage) =>
          this.log('create NotificationTemplate'),
        ),
        catchError(this.handleError('createNotificationTemplate', undefined)),
      )
  }

  updateNotificationTemplate(
    template_name: string,
    template_headers: string,
    template_body: string,
  ): Observable<NotificationTemplate> {
    const params = {
      notification_template: {
        template_headers: template_headers,
        template_body: template_body,
      },
    }

    return this.http
      .put<NotificationTemplate>(
        this.notificationTemplatesUrl + '/' + template_name,
        params,
      )
      .pipe(
        tap((_notificationTemplatePage) =>
          this.log('update NotificationTemplate'),
        ),
        catchError(this.handleError('updateNotificationTemplate', undefined)),
      )
  }

  removeNotificationTemplate(
    template_name: string,
  ): Observable<NotificationTemplate> {
    return this.http
      .delete<NotificationTemplate>(
        this.notificationTemplatesUrl + '/' + template_name,
      )
      .pipe(
        tap((_notificationTemplatePage) =>
          this.log('remove NotificationTemplate'),
        ),
        catchError(this.handleError('removeNotificationTemplate', undefined)),
      )
  }

  private handleError<T>(operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`)
      return of(result as T)
    }
  }

  private log(message: string) {
    console.log('NotificationTemplateService: ' + message)
  }
}
