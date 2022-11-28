import { Component, EventEmitter, Input, Output } from '@angular/core'

import { NotificationEndpointService } from '../../services/notification_endpoint.service'
import { NotificationEndpoint } from '../../models/notification_endpoint'
import { PwdType } from '../../models/pwd_type'

@Component({
  selector: 'notification_endpoint-component',
  templateUrl: 'notification_endpoint.component.html',
  styleUrls: ['./notification_endpoint.component.less'],
})
export class NotificationEndpointComponent {
  @Input() data: NotificationEndpoint
  @Output() deleted: EventEmitter<NotificationEndpoint> =
    new EventEmitter<NotificationEndpoint>()

  pwd_type = PwdType.Password

  constructor(
    private notificationEndpointService: NotificationEndpointService,
  ) {}

  mask(mode) {
    if (mode === true) {
      this.pwd_type = PwdType.Password
    } else {
      this.pwd_type = PwdType.Text
    }
  }

  delete() {
    this.notificationEndpointService
      .removeNotificationEndpoint(this.data.endpoint_placeholder)
      .subscribe((_notificationEndpoint) => {
        this.deleted.next(this.data)
      })
  }
}
