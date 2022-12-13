import { Injectable } from '@angular/core'
import { HttpClient } from '@angular/common/http'
import { Observable, of } from 'rxjs'
import { catchError, tap } from 'rxjs/operators'

import { NotificationEndpoint } from '../models/notification_endpoint'
import { NotificationEndpointPage } from '../models/page/notification_endpoint_page'

@Injectable()
export class NotificationEndpointService {
  private notificationEndpointsUrl = '/api/step_flow/notification_endpoints'

  constructor(private http: HttpClient) {}

  getNotificationEndpoints(): Observable<NotificationEndpointPage> {
    return this.http
      .get<NotificationEndpointPage>(this.notificationEndpointsUrl)
      .pipe(
        tap((_notificationEndpointPage) =>
          this.log('fetched NotificationEndpointPage'),
        ),
        catchError(this.handleError('getNotificationEndpoints', undefined)),
      )
  }

  createNotificationEndpoint(
    endpoint_placeholder: string,
    endpoint_url: string,
    endpoint_credentials?: string,
  ): Observable<NotificationEndpoint> {
    let params = {}
    if (endpoint_credentials !== undefined) {
      params = {
        endpoint_placeholder: endpoint_placeholder,
        endpoint_url: endpoint_url,
        endpoint_credentials: endpoint_credentials,
      }
    } else {
      params = {
        endpoint_placeholder: endpoint_placeholder,
        endpoint_url: endpoint_url,
      }
    }
    return this.http
      .post<NotificationEndpoint>(this.notificationEndpointsUrl, params)
      .pipe(
        tap((_notificationEndpointPage) =>
          this.log('create NotificationEndpoint'),
        ),
        catchError(this.handleError('createNotificationEndpoint', undefined)),
      )
  }

  changeNotificationEndpoint(
    id: number,
    endpoint_placeholder: string,
    endpoint_url: string,
    endpoint_credentials: string,
  ): Observable<NotificationEndpoint> {
    const params = {
      id: id,
      notification_endpoint: {
        endpoint_placeholder: endpoint_placeholder,
        endpoint_url: endpoint_url,
        endpoint_credentials: endpoint_credentials,
      },
    }

    return this.http
      .put<NotificationEndpoint>(
        this.notificationEndpointsUrl + '/' + id,
        params,
      )
      .pipe(
        tap((_notificationEndpointPage) =>
          this.log('change NotificationEndpoint'),
        ),
        catchError(this.handleError('changeNotificationEndpoint', undefined)),
      )
  }

  removeNotificationEndpoint(
    endpoint_placeholder: string,
  ): Observable<NotificationEndpoint> {
    return this.http
      .delete<NotificationEndpoint>(
        this.notificationEndpointsUrl + '/' + endpoint_placeholder,
      )
      .pipe(
        tap((_notificationEndpointPage) =>
          this.log('remove NotificationEndpoint'),
        ),
        catchError(this.handleError('removeNotificationEndpoint', undefined)),
      )
  }

  private handleError<T>(operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`)
      return of(result as T)
    }
  }

  private log(message: string) {
    console.log('NotificationEndpointService: ' + message)
  }
}
