
import {Component, OnInit} from '@angular/core'

import {NotificationEndpointService} from '../../services/notification_endpoint.service'
import {NotificationEndpoint} from '../../models/notification_endpoint'

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

  constructor(
    private notificationEndpointService: NotificationEndpointService,
  ) {}

  ngOnInit() {
    this.listNotificationEndpoints()
  }

  listNotificationEndpoints() {
    this.notificationEndpointService.getNotificationEndpoints()
    .subscribe(notificationEndpointPage => {
      this.notificationEndpoints = notificationEndpointPage.data.sort((a, b) =>
      a.endpoint_placeholder.localeCompare(b.endpoint_placeholder));
    })
  }

  insert() {
    this.notificationEndpointService.createNotificationEndpoint(
      this.endpoint_placeholder,
      this.endpoint_url,
      this.endpoint_credentials
    )
    .subscribe(notificationEndpointPage => {
      this.listNotificationEndpoints()
    })
  }
}