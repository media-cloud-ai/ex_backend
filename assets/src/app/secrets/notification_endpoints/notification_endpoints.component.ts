import { Component } from '@angular/core'

import { NotificationEndpointService } from '../../services/notification_endpoint.service'
import {
  NotificationEndpoint,
  NotificationEndpointEventAction,
  NotificationEndpointEvent,
} from '../../models/notification_endpoint'

@Component({
  selector: 'notification_endpoints-component',
  templateUrl: 'notification_endpoints.component.html',
  styleUrls: ['./notification_endpoints.component.less'],
})
export class NotificationEndpointsComponent {
  notificationEndpoints: NotificationEndpoint[]

  endpoint_placeholder: string
  endpoint_url: string
  endpoint_credentials: string
  selected_notification_endpoint_id = undefined

  constructor(
    private notificationEndpointService: NotificationEndpointService,
  ) {}

  ngOnInit() {
    this.listNotificationEndpoints()
  }

  listNotificationEndpoints() {
    this.notificationEndpointService
      .getNotificationEndpoints()
      .subscribe((notificationEndpointPage) => {
        this.notificationEndpoints = notificationEndpointPage.data.sort(
          (a, b) =>
            a.endpoint_placeholder.localeCompare(b.endpoint_placeholder),
        )
      })
  }

  notificationEndpointHasChanged(event: NotificationEndpointEvent) {
    if (event.action == NotificationEndpointEventAction.Select) {
      this.selected_notification_endpoint_id = event.notification_endpoint.id
    }
    if (event.action == NotificationEndpointEventAction.Save) {
      this.selected_notification_endpoint_id = undefined
    }
  }

  insert() {
    this.notificationEndpointService
      .createNotificationEndpoint(
        this.endpoint_placeholder,
        this.endpoint_url,
        this.endpoint_credentials,
      )
      .subscribe((_notificationEndpointPage) => {
        this.listNotificationEndpoints()
      })
  }
}
